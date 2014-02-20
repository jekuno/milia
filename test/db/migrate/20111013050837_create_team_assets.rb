class CreateTeamAssets < ActiveRecord::Migration
  def change
    create_table :team_assets do |t|
      t.references :tenant, index: true
      t.references :member, index: true
      t.references :team, index: true

      t.timestamps
    end
  end
end
