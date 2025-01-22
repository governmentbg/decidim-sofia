Rails.application.config.to_prepare do
  Decidim::User.class_eval do
    def old_enough?
      return false if auth_uid.blank?

      egn = Egn.parse(auth_uid)

      egn.valid? && 18.years.ago.to_date >= egn.birth_date.to_date
    end
  end
end