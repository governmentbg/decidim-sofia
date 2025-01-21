require_relative "boot"

require "decidim/rails"

# Add the frameworks used by your app that are not loaded by Decidim.
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DecidimBg
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # config.action_dispatch.default_headers = {
    #   'Access-Control-Allow-Origin' => '*'
    # }
    config.active_job.queue_adapter = :delayed_job

    config.hosts << "decidim.nexgen.bg"
    config.hosts << "decidim.lan"
    config.hosts << "localhost"
    config.hosts << "reshava.sofia.bg"

    config.i18n.fallbacks = true
    config.i18n.raise_on_missing_translations = false

    config.i18n.enforce_available_locales = false


    initializer "decidim.core.homepage_content_blocks" do
      Decidim.content_blocks.register(:homepage, :process_steps) do |content_block|
        content_block.cell = "sofia/content_blocks/process_steps"
        content_block.settings_form_cell = "sofia/content_blocks/process_steps_settings_form"
        content_block.public_name_key = "sofia.content_blocks.process_steps.name"

        content_block.settings do |settings|
          settings.attribute :process_id, type: :integer
        end

        content_block.default!
      end

      Decidim.content_blocks.register(:homepage, :process_budgets) do |content_block|
        content_block.cell = "sofia/content_blocks/process_budgets"
        content_block.settings_form_cell = "sofia/content_blocks/process_budgets_settings_form"
        content_block.public_name_key = "sofia.content_blocks.process_budgets.name"

        content_block.settings do |settings|
          settings.attribute :process_id, type: :integer
        end

        content_block.default!
      end
    end

  end

end
