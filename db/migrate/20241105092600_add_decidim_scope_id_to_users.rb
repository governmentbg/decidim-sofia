class AddDecidimScopeIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_users, :scope_id, :integer
  end
end
