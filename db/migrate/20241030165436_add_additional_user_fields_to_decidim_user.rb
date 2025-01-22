class AddAdditionalUserFieldsToDecidimUser < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_users, :auth_status, :string
    add_column :decidim_users, :auth_uid, :string
    add_column :decidim_users, :auth_response, :text
    add_column :decidim_users, :regix_response, :text
    add_column :decidim_users, :regix_status, :string
    add_column :decidim_users, :regix_retry_date, :datetime
  end
end
