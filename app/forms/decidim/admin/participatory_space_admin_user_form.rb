# frozen_string_literal: true

module Decidim
  module Admin
    class ParticipatorySpaceAdminUserForm < ParticipatorySpacePrivateUserForm
      attribute :role, String
      attribute :scope_id, Integer

      validates :scope_id, presence: true
      validates :role, presence: true
      validates :role, inclusion: { in: ParticipatorySpaceUser::ROLES }

      def roles
        ParticipatorySpaceUser::ROLES.map { |role| [I18n.t(role, scope:), role] }
      end

      def map_model(model)
        self.scope_id = model.scope_id
      end
    end
  end
end
