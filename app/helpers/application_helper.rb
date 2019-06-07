# frozen_string_literal: true

module ApplicationHelper
  DANGEROUS_SCOPES = %w(
    read
    write
    follow
  ).freeze

  def active_nav_class(*paths)
    paths.any? { |path| current_page?(path) } ? 'active' : ''
  end

  def active_link_to(label, path, **options)
    link_to label, path, options.merge(class: active_nav_class(path))
  end

  def show_landing_strip?
    !user_signed_in? && !single_user_mode?
  end

  def open_registrations?
    Setting.registrations_mode == 'open'
  end

  def approved_registrations?
    Setting.registrations_mode == 'approved'
  end

  def closed_registrations?
    Setting.registrations_mode == 'none'
  end

  def available_sign_up_path
    if closed_registrations?
      'https://joinmastodon.org/#getting-started'
    else
      new_user_registration_path
    end
  end

  def max_bio_chars
    Setting.max_bio_chars
  end

  def max_toot_chars
    Setting.max_toot_chars
  end

  def open_deletion?
    Setting.open_deletion
  end

  def locale_direction
    if [:ar, :fa, :he].include?(I18n.locale)
      'rtl'
    else
      'ltr'
    end
  end

  def favicon_path
    env_suffix = Rails.env.production? ? '' : '-dev'
    "/favicon#{env_suffix}.ico"
  end

  def title
    Rails.env.production? ? site_title : "#{site_title} (Dev)"
  end

  def class_for_scope(scope)
    'scope-danger' if DANGEROUS_SCOPES.include?(scope.to_s)
  end

  def can?(action, record)
    return false if record.nil?
    policy(record).public_send("#{action}?")
  end

  def fa_icon(icon, attributes = {})
    class_names = attributes[:class]&.split(' ') || []
    class_names << 'fa'
    class_names += icon.split(' ').map { |cl| "fa-#{cl}" }

    content_tag(:i, nil, attributes.merge(class: class_names.join(' ')))
  end

  def custom_emoji_tag(custom_emoji)
    image_tag(custom_emoji.image.url, class: 'emojione', alt: ":#{custom_emoji.shortcode}:")
  end

  def opengraph(property, content)
    tag(:meta, content: content, property: property)
  end

  def react_component(name, props = {}, &block)
    if block.nil?
      content_tag(:div, nil, data: { component: name.to_s.camelcase, props: Oj.dump(props) })
    else
      content_tag(:div, data: { component: name.to_s.camelcase, props: Oj.dump(props) }, &block)
    end
  end

  def body_classes
    output = (@body_classes || '').split(' ')
    output << "theme-#{current_theme.parameterize}"
    output << 'system-font' if current_account&.user&.setting_system_font_ui
    output << (current_account&.user&.setting_reduce_motion ? 'reduce-motion' : 'no-reduce-motion')
    output << 'rtl' if locale_direction == 'rtl'
    output.reject(&:blank?).join(' ')
  end

  def cdn_host
    Rails.configuration.action_controller.asset_host
  end

  def cdn_host?
    cdn_host.present?
  end

  def storage_host
    "https://#{ENV['S3_ALIAS_HOST'].presence || ENV['S3_CLOUDFRONT_HOST']}"
  end

  def storage_host?
    ENV['S3_ALIAS_HOST'].present? || ENV['S3_CLOUDFRONT_HOST'].present?
  end

  def quote_wrap(text, line_width: 80, break_sequence: "\n")
    text = word_wrap(text, line_width: line_width - 2, break_sequence: break_sequence)
    text.split("\n").map { |line| '> ' + line }.join("\n")
  end
end
