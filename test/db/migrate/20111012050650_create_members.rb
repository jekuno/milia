class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.references :tenant, index: true
      t.references :user, index: true
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end
