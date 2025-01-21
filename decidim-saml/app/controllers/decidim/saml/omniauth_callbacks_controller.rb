# frozen_string_literal: true
module Decidim
  module Saml
    class OmniauthCallbacksController < ::Decidim::Devise::OmniauthRegistrationsController
      skip_before_action :verify_authenticity_token
      # skip_before_action :authenticate_decidim_user, only: [:callback]

      def failure
        flash_message = t("authorizations.create.failure", scope: "decidim.saml.verification")

        if params[:SAMLResponse]
          response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], :settings => gsaml_settings)

          response.is_valid?

          if response.errors.any?
            saml_error = response.errors.first.split('->').last.strip

            flash_message = t("authorizations.create.failure_saml", scope: "decidim.saml.verification", message: saml_error)
          end
        end

        flash[:alert] = flash_message

        redirect_to(decidim.root_path)
      end

      def passthru
        request = MyAuthReq.new

        redirect_to(request.create(gsaml_settings))
      end

      def callback
        response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], :settings => gsaml_settings)
        flash_type = :alert
        flash_message = t("authorizations.create.failure", scope: "decidim.saml.verification")

        if response.is_valid? && current_user
          egn = response.attributes['urn:egov:bg:eauth:2.0:attributes:personIdentifier'].split('-').last

          egn_valid = Egn.validate(egn)
          egn_taken = Decidim::User.where(auth_uid: egn, deleted_at: nil)
          already_auth = current_user.auth_uid.present?

          if already_auth
            flash_message = t("authorizations.create.failure_already_verified", scope: "decidim.saml.verification")
          elsif !egn_valid
            flash_message = t("authorizations.create.failure_egn", scope: "decidim.saml.verification")
          elsif egn_taken.any?
            email_split = egn_taken.first.email.split('@')
            hidden_email = "#{mask(email_split[0],2)}@#{mask(email_split[1], 4)}"

            flash_message = t("authorizations.create.failure_taken", hidden_email: hidden_email, scope: "decidim.saml.verification")
          else
            flash_type = :notice
            flash_message = t("authorizations.create.success", scope: "decidim.saml.verification")

            current_user.update(auth_status: 'success', auth_response: params[:SAMLResponse], auth_uid: egn)

            Decidim::Authorization.create(
              name: :valid_sso,
              decidim_user_id:  current_user.id,
              unique_id:        current_user.auth_uid,
              granted_at:         Time.now
            )

            Decidim::Regix.process(current_user)

            if current_user.regix_status == 'success'
              #flash_type = :notice
              #flash_message = t("authorizations.create.success", scope: "decidim.saml.verification")

              flash_message << "<BR /><BR />".html_safe
              budget = Decidim::Budgets::Budget.joins(:scope).where(decidim_scopes:{code: current_user.region}).first
              flash_message << t("current_region", scope: "decidim.account.regix.welcome",
                                 link: "#{budget.title["bg"]}" )
              # link: "<a href=\"/processes/grazhdanski-budget2024/f/1/budgets/#{budget.id}/projects\">#{budget.title["bg"]}</a>" )
            end
          end
        else
          current_user.update(auth_status: 'failure',  auth_response: params[:SAMLResponse])
        end

        flash[flash_type] = flash_message

        redirect_to(decidim.root_path)
      end

      private

      def mask(string, all_but = 4, char = '*')
        (string || '').gsub(/.(?=.{#{all_but}})/, char)
      end

      def gsaml_settings
        idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new

        # saml_settings = idp_metadata_parser.parse_remote("https://eauth-test.egov.bg/tfauthbe/saml/metadata/idp")
        saml_settings = idp_metadata_parser.parse_remote("https://eauth.egov.bg/tfauthbe/saml/metadata/idp")

        saml_settings.assertion_consumer_service_url = "https://reshava.sofia.bg/users/auth/saml/callback"
        saml_settings.sp_entity_id                   = "https://reshava.sofia.bg/users/auth/saml/metadata"
        # saml_settings.name_identifier_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
        # Optional for most SAML IdPs
        # saml_settings.authn_context = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
        # saml_settings.sp_entity_id = 'reshava.sofia.bg'
        saml_settings.certificate = Rails.application.credentials.dig(:saml_cert)
        saml_settings.private_key = Rails.application.credentials.dig(:saml_key)
        # saml_settings.compress_request = true
        saml_settings.force_authn = true
        saml_settings.passive = false
        saml_settings.name_identifier_format = nil
        saml_settings.authn_context = nil
        saml_settings.authn_context_decl_ref = nil
        saml_settings.protocol_binding = 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST'
        saml_settings.security[:metadata_signed] = true
        saml_settings.security[:authn_requests_signed] = true
        saml_settings.security[:want_assertions_encrypted] = true
        saml_settings.security[:digest_method] = XMLSecurity::Document::SHA256
        saml_settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA1

        saml_settings
      end
    end
  end
end
