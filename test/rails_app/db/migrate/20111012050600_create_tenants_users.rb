class CreateTenantsUsers < ActiveRecord::Migration
  def change
    create_table :tenants_users, :id => false  do |t|
      t.references   :tenant
      t.references   :user
    end
    add_index :tenants_users, :tenant_id
    add_index :tenants_users, :user_id
  end
end
