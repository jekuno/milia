class CreateTeamAssets < ActiveRecord::Migration
  def change
    create_table :team_assets do |t|
      t.references :tenant
      t.references :author
      t.references :team

      t.timestamps
    end
    add_index :team_assets, :tenant_id
    add_index :team_assets, :author_id
    add_index :team_assets, :team_id
  end
end
