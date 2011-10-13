class CreateZines < ActiveRecord::Migration
  def change
    create_table :zines do |t|
      t.references :tenant
      t.references :calendar

      t.timestamps
    end
    add_index :zines, :tenant_id
    add_index :zines, :calendar_id
  end
end
