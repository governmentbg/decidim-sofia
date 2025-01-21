class AddVoteSelectedProjectsMaximumToDecidimBudgets < ActiveRecord::Migration[6.1]
  def change
    add_column :decidim_budgets_budgets, :vote_selected_projects_maximum, :integer
  end
end
