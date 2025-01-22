# frozen_string_literal: true

module Decidim
  module ValidSso
    class AuthorizationsController < Decidim::Verifications::ApplicationController
      #before_action :load_authorization

      skip_before_action :verify_authenticity_token, only: [:validate]
      # skip_after_action :verify_same_origin_request, only: [:validate]
      # skip_before_action :verify_authenticity_token

      def new
        # enforce_permission_to :create, :authorization, authorization: @authorization
      end

      def validate
        return redirect_to root_path

        enforce_permission_to :create, :authorization, authorization: @authorization

        @form = ValidAuthForm.from_params(params.merge(user: current_user))

        ValidateValidAuth.call(@authorization, @form) do
          on(:ok) do
            flash[:notice] = t("authorizations.create.success", scope: "decidim.valid_auth")
            redirect_to decidim_verifications.authorizations_path
          end

          on(:invalid) do
            flash[:alert] = t("authorizations.create.error", scope: "decidim.valid_auth")
            redirect_to decidim_verifications.authorizations_path
          end
        end
      end

      private

      # def valid_link
      #   validate_authorization_url
      #   # Rails.application.secrets.valid_auth_url + validate_authorization_url
      # end

      def load_authorization
        @authorization = Decidim::Authorization.find_or_initialize_by(
          user: current_user,
          name: "valid_sso"
        )
      end
    end
  end
end