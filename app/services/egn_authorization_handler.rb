# frozen_string_literal: true

# Checks the authorization against the census for Barcelona.
require "digest/md5"

# This class performs a check against the official census database in order
# to verify the citizen's residence.
class EgnAuthorizationHandler < Decidim::AuthorizationHandler
  include ActionView::Helpers::SanitizeHelper

  attribute :egn, String

  validates :egn, presence: true

  validate :valid_egn
  validate :valid_region
  validate :not_voted

  # If you need to store any of the defined attributes in the authorization you
  # can do it here.
  #
  # You must return a Hash that will be serialized to the authorization when
  # it's created, and available though authorization.metadata

  def unique_id
    Digest::MD5.hexdigest(
      "#{egn}-#{Time.now.to_i}-#{Rails.application.secrets.secret_key_base}"
    )
  end

  private

  def extract_region
    @region ||= Decidim::Regix.find_region(egn)
  end

  def valid_region
    if extract_region[:municipality].to_i == 46 && extract_region[:region].to_i > 0
      user.region = extract_region[:region]
      user.regix_status = :success
    else
      errors.add(:egn, :invalid_region)
    end
  end

  def valid_egn
    if Egn.validate(egn)
      user.auth_uid = egn
      user.auth_status = :manual
    else
      errors.add(:egn, :invalid)
    end
  end

  def not_voted
    if u_ids = Decidim::User.where(auth_uid: egn).ids
      votes = Decidim::Budgets::Order.
        where(decidim_user_id: u_ids).
        where.not(checked_out_at: nil).
        count

      if Decidim::User.where(id: u_ids, auth_status: 'success').any?
        errors.add(:egn, :already_registered)
      elsif votes > 0
        errors.add(:egn, :already_voted)
      end
    end
  end
end