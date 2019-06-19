# frozen_string_literal: true

module Mastodon
  module Version
    module_function

    # equivalent mastodon version
    module Equiv
      module_function

      def major
        2
      end

      def minor
        9
      end

      def patch
        0
      end

      def pre
        nil
      end

      def flags
        ''
      end

      def to_a
        [major, minor, patch, pre].compact
      end

      def suffix
        ['+', Version.flavor].join
      end

      def to_s
        [to_a.join('.'), flags, suffix].join
      end

      def repository
        Version.repository
      end

      def source_base_url
        Version.source_base_url
      end

      def source_tag
        Version.source_tag
      end

      def source_url
        Version.source_url
      end

      def user_agent
        @user_agent ||= "#{HTTP::Request::USER_AGENT} (Mastodon/#{Equiv}; +http#{Rails.configuration.x.use_https ? 's' : ''}://#{Rails.configuration.x.web_domain}/)"
      end
    end

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
        ''
    end

    def flavor
      'florence'
    end

    def to_a
      [compat, feel, feature, hotfix]
    end

    def to_s
      to_a.push(suffix).join('.')
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
