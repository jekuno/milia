class CreateTenantsUsersJoinTable < ActiveRecord::Migration
  def change
    create_join_table :tenants, :users do |t|
      t.index [:tenant_id, :user_id]
      # t.index [:user_id, :tenant_id]
    end
  end
end
