# frozen_string_literal: true

module Florence
  module Version
    module_function

    def compatibility
      0
    end

    def feel
      0
    end

    def feature
      1
    end

    def hotfix
      1
    end

    def suffix
      ''
    end

    def to_a
      [compatibility, feel, feature, hotfix]
    end

    def to_s
      [to_a.join('.'), suffix].join
    end
  end
end

