# frozen_string_literal: true

if Rails.env.production?
  Sentry.init do |config|
    config.dsn = 'https://1b65aa3a20e626bf2161c6d2f457ca6a@o4508261702303744.ingest.de.sentry.io/4508285164978256'
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]

    # Set traces_sample_rate to 1.0 to capture 100%
    # of transactions for tracing.
    # We recommend adjusting this value in production.
    config.traces_sample_rate = 1.0
    # or
    config.traces_sampler = lambda do |context|
      true
    end
end
end