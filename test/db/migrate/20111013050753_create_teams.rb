class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.references :tenant
      t.string :name

      t.timestamps
    end
    add_index :teams, :tenant_id
  end
end
