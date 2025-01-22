# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          if permission_action.action.in?([:manage])
            permission_action.allow! if user.scope_id != (budget || project)&.decidim_scope_id
          end

          return permission_action if permission_action.scope != :admin

          case permission_action.subject
          when :budget
            case permission_action.action
            when :create, :read, :export
              allow!
            when :update
              toggle_allow(budget)
            when :delete, :publish, :unpublish
              toggle_allow(budget && budget.projects.empty?)
            end
          when :project, :projects
            case permission_action.action
            when :create, :import_proposals, :project_category
              permission_action.allow!
            when :update, :destroy
              permission_action.allow! if project.present?
            end
          when :order
            case permission_action.action
            when :remind
              permission_action.allow!
            end
          when :project_category, :project_scope, :project_selected
            permission_action.allow!
          end

          case permission_action.action
          when :update, :delete, :public, :unpublish, :destroy
            if !user.admin? && (budget || project)&.decidim_scope_id.present?
              permission_action.disallow! if user.scope_id != (budget || project)&.decidim_scope_id
            end
          when :create, :remind, :export, :order
            permission_action.disallow! if permission_action.subject == :budget
            permission_action.disallow! if permission_action.action == :remind
          end

          permission_action
        end

        private

        def budget
          @budget ||= context.fetch(:budget, nil)
        end

        def project
          @project ||= context.fetch(:project, nil)
        end
      end
    end
  end
end