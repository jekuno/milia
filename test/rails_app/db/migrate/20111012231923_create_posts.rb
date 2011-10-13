class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.references :tenant
      t.references :user
      t.string :content

      t.timestamps
    end
    add_index :posts, :tenant_id
    add_index :posts, :user_id
  end
end
