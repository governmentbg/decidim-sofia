require "omniauth"
require "omniauth-saml"

require "omniauth/rails_csrf_protection"

require "decidim/valid_sso/version"
require "decidim/valid_sso/engine"

require_relative "valid_sso/authentication"

module Decidim
  module ValidSso
    include ActiveSupport::Configurable

    # Your code goes here...
    config_accessor :authenticator_class do
      Decidim::ValidSso::Authentication::Authenticator
    end
    def self.authenticator_for(organization, oauth_hash)
      authenticator_class.new(organization, oauth_hash)
    end
  end
end
