# frozen_string_literal: true

Bugsnag.configure do |config|
  config.api_key = '6555bb368974952073d50bed088a6877'
  config.notify_release_stages = %w[production staging]
  config.app_version = FatFreeCRM::Application::VERSION
end
