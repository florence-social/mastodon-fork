# frozen_string_literal: true

module Mastodon
  module Version
    module_function

    def compat
      0
    end

    def feel
      0
    end

    def feature
      1
    end

    def hotfix
      0
    end

    def suffix
      '+florence'
    end

    def to_a
      [compat, feel, feature, hotfix]
    end

    def to_s
      to_a.join('.') + suffix
    end

    def repository
      ENV.fetch('GITHUB_REPOSITORY') { 'florence-social/mastodon-fork' }
    end

    def source_base_url
      ENV.fetch('SOURCE_BASE_URL') { "https://github.com/#{repository}" }
    end

    # specify git tag or commit hash here
    def source_tag
      ENV.fetch('SOURCE_TAG') { nil }
    end

    def source_url
      if source_tag
        "#{source_base_url}/tree/#{source_tag}"
      else
        source_base_url
      end
    end

    def user_agent
      @user_agent ||= "#{HTTP::Request::USER_AGENT} (FlorenceMastodon/#{Version}; +http#{Rails.configuration.x.use_https ? 's' : ''}://#{Rails.configuration.x.web_domain}/)"
    end
  end
end
