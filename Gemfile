# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim", "0.28.4"
gem "decidim-core", "0.28.4"
# gem "decidim-conferences", "0.28.0"
# gem "decidim-design", "0.28.0"
# gem "decidim-elections", "0.28.0"
# gem "decidim-initiatives", "0.28.0"
# gem "decidim-templates", "0.28.0"

gem "bootsnap", "~> 1.3"

gem "puma", ">= 6.3.1"

gem "wicked_pdf", "~> 2.1"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "brakeman", "~> 5.4"
  gem "decidim-dev", "0.28.4"
  gem "net-imap", "~> 0.2.3"
  gem "net-pop", "~> 0.1.1"
  gem "net-smtp", "~> 0.3.1"
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 4.2"
  gem 'pry'
  gem "capistrano", "~> 3.17", require: false
  gem "capistrano-rails", "~> 1.6", require: false
  gem 'capistrano-rvm'
  gem 'capistrano-rails-console', require: false
  gem 'capistrano3-puma', github: "seuros/capistrano-puma"
  gem 'capistrano-delayed-job', '~> 1.0'
end

group :production do
end

gem 'decidim-saml', path: 'decidim-saml'
gem 'decidim-valid_sso', path: 'decidim-valid_sso'
gem "decidim-term_customizer", github: 'mainio/decidim-module-term_customizer'
gem "ruby-saml", path: 'decidim-ruby-saml'
gem 'egn'
gem 'delayed_job_active_record'
gem 'daemons'
gem 'mini_portile2'
gem "sentry-ruby"
gem "sentry-rails"
gem "redis"