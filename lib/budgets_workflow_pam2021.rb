# frozen_string_literal: true

# Specific Workflow for Barcelona's 2021 PAM
class BudgetsWorkflowPam2021 < Decidim::Budgets::Workflows::Base
  PAM2021AUTHORIZATIONHANDLER = "egn_authorization_handler"

  # The budget resource in the user's scope is highlighted.
  def highlighted?(resource)
    return unless user_scope_resource && !voted?(user_scope_resource)

    resource == user_scope_resource
  end

  # Can vote in the budget resource in the user's scope
  # and in an extra budget resource out of its scope
  # rubocop:disable Style/OptionalBooleanParameter
  def vote_allowed?(resource, consider_progress = true)
    return false unless resource
    return false unless user
    return false unless user.old_enough?

    resource.in?(user_scope_resources)

    # return true if resource == user_scope_resource

    # resources_with_order = voted
    # resources_with_order += progress if consider_progress
    #
    # (resources_with_order - [user_scope_resource, resource]).empty?
  end

  # rubocop:enable Style/OptionalBooleanParameter

  # The user can change of mind and change the vote on these budget resources
  #
  # Returns Array.
  # def discardable
  #   (voted + progress) - [user_scope_resource]
  # end

  # The user can vote on maximum 2 budget resources
  #
  # Returns Boolean.
  def limit_reached?
    # (voted + progress).count >= 2
    false
  end

  private

  # Returns Object (Authorization).
  def user_authorization
    @user_authorization ||= Decidim::Authorization.find_by(
      name: PAM2021AUTHORIZATIONHANDLER,
      user:
    )
  end

  # The budget resources the user can and should vote on
  #
  # Returns Object (Decidim::Budgets:Budget).
  def user_scope_resource
    return unless user_authorization_scope

    @user_scope_resource ||= budgets.find do |resource|
      resource.scope == user_authorization_scope
    end
  end
  def user_scope_resources
    return [] unless user_authorization_scope

    @user_scope_resources ||= budgets.select do |resource|
      resource.scope == user_authorization_scope ||
        resource.scope == user_authorization_scope&.parent
    end
  end

  # The user's scope from the verifcation
  #
  # Returns Object (Scope).
  def user_authorization_scope
    return unless user

    @user_authorization_scope ||= Decidim::Scope.find_by(code: user.region)
  end
end