class CreateTenants < ActiveRecord::Migration
  def change
    create_table :tenants do |t|
      t.references :tenant

      t.timestamps
    end
  end
end
