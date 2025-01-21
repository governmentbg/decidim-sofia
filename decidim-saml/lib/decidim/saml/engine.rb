module Decidim
  module Saml
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Saml

      routes do
        devise_scope :user do
          # Manually map the SAML omniauth routes for Devise because the default
          # routes are mounted by core Decidim. This is because we want to map
          # these routes to the local callbacks controller instead of the
          # Decidim core.
          # See: https://git.io/fjDz1
          match(
            "/users/auth/saml/callback",
            to: "/decidim/saml/omniauth_callbacks#callback",
            as: "user_saml_omniauth_callback",
            via: [:get, :post]
          )


          match(
            "/users/auth/saml_custom",
            to: "/decidim/saml/omniauth_callbacks#passthru",
            as: "user_saml_omniauth_authorize_custom",
            via: [:post]
          )
        end
      end

      initializer "decidim_saml.mount_routes", before: :add_routing_paths do
        # Mount the engine routes to Decidim::Core::Engine because otherwise
        # they would not get mounted properly. Note also that we need to prepend
        # the routes in order for them to override Decidim's own routes for the
        # "suomifi" authentication.
        Decidim::Core::Engine.routes.prepend do
          mount Decidim::Saml::Engine => "/"
        end
      end

      initializer "decidim_saml.setup", before: "devise.omniauth" do

        # Configure the SAML OmniAuth strategy for Devise
        ::Devise.setup do |config|
          idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
          # iidp_metadata = idp_metadata_parser.parse_remote_to_hash('https://eauth-test.egov.bg/tfauthbe/saml/metadata/idp')
          iidp_metadata = idp_metadata_parser.parse_remote_to_hash('https://eauth.egov.bg/tfauthbe/saml/metadata/idp')

          config.omniauth(
            :saml,
            iidp_metadata.merge(
              :assertion_consumer_service_url => "https://reshava.sofia.bg/users/auth/saml/callback",
              sp_entity_id: 'https://reshava.sofia.bg/users/auth/saml/metadata',
              certificate: Rails.application.credentials.dig(:saml_cert),
              private_key: Rails.application.credentials.dig(:saml_key),
              compress_request: true,
              force_authn: true,
              passive: false,
              name_identifier_format: nil,
              authn_context: nil,
              authn_context_decl_ref: nil,
              request_attributes: [],
              protocol_binding: 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',
              security: {
                metadata_signed: true,
                want_assertions_encrypted: true,
                authn_requests_signed: true, # true production
                digest_method: XMLSecurity::Document::SHA256,
                signature_method: XMLSecurity::Document::RSA_SHA1
              }
            )
          )
        end

        # Customized version of Devise's OmniAuth failure app in order to handle
        # the failures properly. Without this, the failure requests would end
        # up in an ActionController::InvalidAuthenticityToken exception.

        devise_failure_app = OmniAuth.config.on_failure
        OmniAuth.config.on_failure = proc do |env|
          if env["PATH_INFO"].match?(%r{^/users/auth/saml(/.*)?})
            env["devise.mapping"] = ::Devise.mappings[:user]
            Decidim::Saml::OmniauthCallbacksController.action(
              :failure
            ).call(env)
          else
            # Call the default for others.
            devise_failure_app.call(env)
          end
        end
      end
    end
  end
end
