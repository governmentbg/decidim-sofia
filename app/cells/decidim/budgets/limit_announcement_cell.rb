# frozen_string_literal: true

module Decidim
  module Budgets
    # This cell renders information when current user cannot create more budgets orders.
    class LimitAnnouncementCell < BaseCell
      alias budget model
      delegate :voted?, :vote_allowed?, :discardable, :limit_reached?, to: :current_workflow
      delegate :voting_open?, to: :controller

      def show
        render if announce?
      end

      private

      def announce?
        return unless voting_open?
        return unless current_user
        return if vote_allowed?(budget)
        return if voted?(budget)

        discardable.any? || !vote_allowed?(budget, consider_progress: false)
      end

      def announcement_message
        # binding.pry
        if discardable.any?
          t(:limit_reached, scope: i18n_scope,
                            links: budgets_link_list(discardable),
                            landing_path: budgets_path)
        else


          #todo: hardcoded region
          if current_user.regix_status == "success" && budget.scope.code != "00" && budget.scope.code != current_user.region

            user_budget = Decidim::Budgets::Budget.joins(:scope).where(decidim_scopes:{code: current_user.region}).last
            link = link_to(user_budget.title["bg"], budget_path(user_budget)) rescue '#'
            t(:cant_vote_region, scope: i18n_scope, link: link)
          else
            t(:cant_vote, scope: i18n_scope, landing_path: budgets_path)
          end
          # binding.pry
          #todo: add region

        end
      end

      def should_discard_to_vote?
        limit_reached? && discardable.any?
      end

      def i18n_scope
        "decidim.budgets.limit_announcement"
      end
    end
  end
end
