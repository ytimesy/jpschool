Rails.application.configure do
  config.eager_load = true
  config.consider_all_requests_local = false

  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.active_support.report_deprecations = false

  config.force_ssl = true
  config.log_tags = [:request_id]
end
