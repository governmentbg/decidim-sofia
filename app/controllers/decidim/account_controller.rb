# frozen_string_literal: true

module Decidim
  # The controller to handle the user's account page.
  class AccountController < Decidim::ApplicationController
    include Decidim::UserProfile

    helper Decidim::PasswordsHelper

    def regix

      unless DateTime.now > current_user.regix_retry_date
        flash[:alert] = t("regix_time_exceeded", scope: "decidim.account.regix")
        return redirect_back(fallback_location: root_path)
      end


      old_region = current_user.region
      result =  Decidim::Regix.process(current_user)

      if result

        #todo: set better flash message
        if old_region != current_user.region
          flash_message = t("regix_success", scope: "decidim.account.regix")

          flash_message << "<BR />".html_safe
          budget = Decidim::Budgets::Budget.joins(:scope).where(decidim_scopes:{code: current_user.region}).first
          flash_message << t("current_region", scope: "decidim.account.regix.welcome",
                             link: "#{budget.title["bg"]}" )

        else
          flash_message = t("regix_success", scope: "decidim.account.regix")

          flash_message << "<BR />".html_safe
          budget = Decidim::Budgets::Budget.joins(:scope).where(decidim_scopes:{code: current_user.region}).first
          flash_message << t("current_region", scope: "decidim.account.regix.welcome",
                             link: "#{budget.title["bg"]}" )
        end



        flash[:notice] = flash_message

      else
        flash[:alert] = t("regix_error", scope: "decidim.account.regix")
      end

      redirect_back(fallback_location: root_path)
    end

    def show
      enforce_permission_to(:show, :user, current_user:)
      @account = form(AccountForm).from_model(current_user)
      @account.password = nil

      # flash_type = :notice
      # flash_message = t("authorizations.create.success", scope: "decidim.saml.verification")
      #
      # flash_message << "<BR />".html_safe
      # budget = Decidim::Budgets::Budget.joins(:scope).where(decidim_scopes:{code: current_user.region}).first
      # flash_message << t("current_region", scope: "decidim.account.regix.welcome",
      #                    link: "#{budget.title["bg"]}" )
      #                    # link: "<a href=\"/processes/grazhdanski-budget2024/f/1/budgets/#{budget.id}/projects\">#{budget.title["bg"]}</a>" )
      #
      # flash[flash_type] = flash_message

    end

    def update
      enforce_permission_to(:update, :user, current_user:)
      @account = form(AccountForm).from_params(account_params)
      UpdateAccount.call(current_user, @account) do
        on(:ok) do |email_is_unconfirmed|
          flash[:notice] = if email_is_unconfirmed
                             t("account.update.success_with_email_confirmation", scope: "decidim")
                           else
                             t("account.update.success", scope: "decidim")
                           end

          bypass_sign_in(current_user)
          redirect_to account_path(locale: current_user.reload.locale)
        end

        on(:invalid) do |password|
          fetch_entered_password(password)
          flash[:alert] = t("account.update.error", scope: "decidim")
          render action: :show
        end
      end
    end

    def delete
      enforce_permission_to(:delete, :user, current_user:)
      @form = form(DeleteAccountForm).from_model(current_user)
    end

    def destroy
      enforce_permission_to(:delete, :user, current_user:)
      @form = form(DeleteAccountForm).from_params(params)

      DestroyAccount.call(current_user, @form) do
        on(:ok) do
          sign_out(current_user)
          flash[:notice] = t("account.destroy.success", scope: "decidim")
        end

        on(:invalid) do
          flash[:alert] = t("account.destroy.error", scope: "decidim")
        end
      end

      redirect_to decidim.root_path
    end

    def resend_confirmation_instructions
      enforce_permission_to(:update, :user, current_user:)

      ResendConfirmationInstructions.call(current_user) do
        on(:ok) do
          respond_to do |format|
            handle_alert(:success, t("resend_successfully", scope: "decidim.account.email_change", unconfirmed_email: current_user.unconfirmed_email))
            format.js
          end
        end

        on(:invalid) do
          respond_to do |format|
            handle_alert(:alert, t("resend_error", scope: "decidim.account.email_change"))
            format.js
          end
        end
      end
    end

    def cancel_email_change
      enforce_permission_to(:update, :user, current_user:)

      if current_user.unconfirmed_email
        current_user.update(unconfirmed_email: nil)

        respond_to do |format|
          handle_alert(:success, t("cancel_successfully", scope: "decidim.account.email_change"))
          format.js
        end
      else
        respond_to do |format|
          handle_alert(:alert, t("cancel_error", scope: "decidim.account.email_change"))
          format.js
        end
      end
    end

    private

    def handle_alert(alert_class, text)
      @alert_class = alert_class
      @text = text
    end

    def account_params
      params[:user].to_unsafe_h
    end

    def fetch_entered_password(password)
      @account.password = password
    end
  end
end
