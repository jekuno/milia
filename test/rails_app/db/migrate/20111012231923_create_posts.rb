class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.references :tenant
      t.references :author
      t.references :zine
      t.string :content

      t.timestamps
    end
    add_index :posts, :tenant_id
    add_index :posts, :author_id
    add_index :posts, :zine_id
  end
end
