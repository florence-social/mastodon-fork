# frozen_string_literal: true

class ManifestSerializer < ActiveModel::Serializer
  include RoutingHelper
  include ActionView::Helpers::TextHelper

  attributes :name, :short_name, :description,
             :icons, :theme_color, :background_color,
             :display, :start_url, :scope,
             :share_target

  def name
    object.site_title
  end

  def short_name
    object.site_title
  end

  def description
    strip_tags(object.site_short_description.presence || I18n.t('about.about_mastodon_html'))
  end

  def icons
    [
      {
        src: '/android-chrome-192x192.png',
        sizes: '192x192',
        type: 'image/png',
      },
    ]
  end

  def theme_color
    '#282c37'
  end

  def background_color
    '#191b22'
  end

  def display
    'standalone'
  end

  def start_url
    '/web/timelines/home'
  end

  def scope
    root_url
  end

  def share_target
    {
      url_template: 'share?title={title}&text={text}&url={url}',
      action: 'share',
      params: {
        title: 'title',
        text: 'text',
        url: 'url',
      },
    }
  end
end
