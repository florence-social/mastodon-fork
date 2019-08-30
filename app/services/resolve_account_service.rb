# frozen_string_literal: true

class ResolveAccountService < BaseService
  include OStatus2::MagicKey
  include JsonLdHelper

  DFRN_NS = 'http://purl.org/macgirvin/dfrn/1.0'

  # Find or create a local account for a remote user.
  # When creating, look up the user's webfinger and fetch all
  # important information from their feed
  # @param [String, Account] uri User URI in the form of username@domain
  # @param [Hash] options
  # @return [Account]
  def call(uri, options = {})
    @options = options

    if uri.is_a?(Account)
      @account  = uri
      @username = @account.username
      @domain   = @account.domain
      uri       = "#{@username}@#{@domain}"

      return @account if @account.local? || !webfinger_update_due?
    else
      @username, @domain = uri.split('@')

      return Account.find_local(@username) if TagManager.instance.local_domain?(@domain)

      @account = Account.find_remote(@username, @domain)

      return @account unless webfinger_update_due?
    end

    Rails.logger.debug "Looking up webfinger for #{uri}"

    @webfinger = Goldfinger.finger("acct:#{uri}")

    confirmed_username, confirmed_domain = @webfinger.subject.gsub(/\Aacct:/, '').split('@')

    if confirmed_username.casecmp(@username).zero? && confirmed_domain.casecmp(@domain).zero?
      @username = confirmed_username
      @domain   = confirmed_domain
    elsif options[:redirected].nil?
      return call("#{confirmed_username}@#{confirmed_domain}", options.merge(redirected: true))
    else
      Rails.logger.debug 'Requested and returned acct URIs do not match'
      return
    end

    return if links_missing?
    return Account.find_local(@username) if TagManager.instance.local_domain?(@domain)

    RedisLock.acquire(lock_options) do |lock|
      if lock.acquired?
        @account = Account.find_remote(@username, @domain)

        if activitypub_ready? || @account&.activitypub?
          handle_activitypub
        else
          handle_ostatus
        end
      else
        raise Mastodon::RaceConditionError
      end
    end

    @account
  rescue Goldfinger::Error => e
    Rails.logger.debug "Webfinger query for #{uri} unsuccessful: #{e}"
    nil
  end

  private

  def links_missing?
    !(activitypub_ready? || ostatus_ready?)
  end

  def ostatus_ready?
    !(@webfinger.link('http://schemas.google.com/g/2010#updates-from').nil? ||
      @webfinger.link('salmon').nil? ||
      @webfinger.link('http://webfinger.net/rel/profile-page').nil? ||
      @webfinger.link('magic-public-key').nil? ||
      canonical_uri.nil? ||
      hub_url.nil?)
  end

  def webfinger_update_due?
    @account.nil? || ((!@options[:skip_webfinger] || @account.ostatus?) && @account.possibly_stale?)
  end

  def activitypub_ready?
    !@webfinger.link('self').nil? &&
      ['application/activity+json', 'application/ld+json; profile="https://www.w3.org/ns/activitystreams"'].include?(@webfinger.link('self').type) &&
      !actor_json.nil? &&
      actor_json['inbox'].present?
  end

  def handle_ostatus
    create_account if @account.nil?
    update_account
    update_account_profile if update_profile?
  end

  def update_profile?
    @options[:update_profile]
  end

  def handle_activitypub
    return if actor_json.nil?

    @account = ActivityPub::ProcessAccountService.new.call(@username, @domain, actor_json)
  rescue Oj::ParseError
    nil
  end

  def create_account
    Rails.logger.debug "Creating new remote account for #{@username}@#{@domain}"

    @account = Account.new(username: @username, domain: @domain)
    @account.suspended_at = domain_block.created_at if auto_suspend?
    @account.silenced_at  = domain_block.created_at if auto_silence?
    @account.private_key  = nil
  end

  def update_account
    @account.last_webfingered_at = Time.now.utc
    @account.protocol            = :ostatus
    @account.remote_url          = atom_url
    @account.salmon_url          = salmon_url
    @account.url                 = url
    @account.public_key          = public_key
    @account.uri                 = canonical_uri
    @account.hub_url             = hub_url
    @account.save!
  end

  def auto_suspend?
    domain_block&.suspend?
  end

  def auto_silence?
    domain_block&.silence?
  end

  def domain_block
    return @domain_block if defined?(@domain_block)
    @domain_block = DomainBlock.rule_for(@domain)
  end

  def atom_url
    @atom_url ||= @webfinger.link('http://schemas.google.com/g/2010#updates-from').href
  end

  def salmon_url
    @salmon_url ||= @webfinger.link('salmon').href
  end

  def actor_url
    @actor_url ||= @webfinger.link('self').href
  end

  def url
    @url ||= @webfinger.link('http://webfinger.net/rel/profile-page').href
  end

  def public_key
    @public_key ||= magic_key_to_pem(@webfinger.link('magic-public-key').href)
  end

  def canonical_uri
    return @canonical_uri if defined?(@canonical_uri)

    author_uri = atom.at_xpath('/xmlns:feed/xmlns:author/xmlns:uri')

    if author_uri.nil?
      owner      = atom.at_xpath('/xmlns:feed').at_xpath('./dfrn:owner', dfrn: DFRN_NS)
      author_uri = owner.at_xpath('./xmlns:uri') unless owner.nil?
    end

    @canonical_uri = author_uri.nil? ? nil : author_uri.content
  end

  def hub_url
    return @hub_url if defined?(@hub_url)

    hubs     = atom.xpath('//xmlns:link[@rel="hub"]')
    @hub_url = hubs.empty? || hubs.first['href'].nil? ? nil : hubs.first['href']
  end

  def atom_body
    return @atom_body if defined?(@atom_body)

    @atom_body = Request.new(:get, atom_url).perform do |response|
      raise Mastodon::UnexpectedResponseError, response unless response.code == 200
      response.body_with_limit
    end
  end

  def actor_json
    return @actor_json if defined?(@actor_json)

    json        = fetch_resource(actor_url, false)
    @actor_json = supported_context?(json) && equals_or_includes_any?(json['type'], ActivityPub::FetchRemoteAccountService::SUPPORTED_TYPES) ? json : nil
  end

  def atom
    return @atom if defined?(@atom)
    @atom = Nokogiri::XML(atom_body)
  end

  def update_account_profile
    RemoteProfileUpdateWorker.perform_async(@account.id, atom_body.force_encoding('UTF-8'), false)
  end

  def lock_options
    { redis: Redis.current, key: "resolve:#{@username}@#{@domain}" }
  end
end
