require_relative 'boot'
require 'rails/all'

Bundler.require(*Rails.groups)

module Jpschool
  class Application < Rails::Application
    config.load_defaults 8.0
    config.time_zone = 'Asia/Tokyo'
    config.i18n.default_locale = :ja
  end
end
