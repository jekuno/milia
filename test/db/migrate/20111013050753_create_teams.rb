class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.references :tenant, index: true
      t.string :name

      t.timestamps
    end
  end
end
