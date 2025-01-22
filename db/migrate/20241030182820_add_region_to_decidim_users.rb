class AddRegionToDecidimUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_users, :region, :string
  end
end
