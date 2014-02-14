class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.references :tenant, index: true
      t.references :member, index: true
      t.references :zine, index: true
      t.string :content

      t.timestamps
    end
  end
end
