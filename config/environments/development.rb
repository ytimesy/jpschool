Rails.application.configure do
  config.eager_load = false
  config.consider_all_requests_local = true
  config.server_timing = true

  config.cache_store = :memory_store
  config.action_controller.perform_caching = false

  config.active_support.deprecation = :log
  config.active_record.migration_error = false
  config.active_record.verbose_query_logs = true

  config.assets.debug = true
  config.assets.quiet = true
end
