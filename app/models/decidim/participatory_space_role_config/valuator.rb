# frozen_string_literal: true

module Decidim
  module ParticipatorySpaceRoleConfig
    class Valuator < Base
      def accepted_components
        [:proposals, :budgets]
      end
    end
  end
end
