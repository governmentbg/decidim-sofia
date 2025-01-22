module Decidim
  module ValidSso
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::ValidSso

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        devise_scope :user do
          # Manually map the SAML omniauth routes for Devise because the default
          # routes are mounted by core Decidim. This is because we want to map
          # these routes to the local callbacks controller instead of the
          # Decidim core.
          # See: https://git.io/fjDz1


        end
        resource :authorizations, only: [:new, :create, :edit, :update, :destroy], as: :authorization do
          get :renew, on: :collection
        end

        root to: "authorizations#new"
      end

      # frozen_string_literal: true
      initializer "decidim_verifications_valid_sso.workflow" do |_app|
        Decidim::Verifications.register_workflow(:valid_sso) do |workflow|
          workflow.engine = Decidim::ValidSso::Engine
        end
      end
    end
  end
end
