class CreateAuthors < ActiveRecord::Migration
  def change
    create_table :authors do |t|
      t.references :tenant
      t.references :user
      t.string :name

      t.timestamps
    end
    add_index :authors, :tenant_id
    add_index :authors, :user_id
  end
end
