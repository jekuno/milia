class CreateCalendars < ActiveRecord::Migration
  def change
    create_table :calendars do |t|
      t.references :tenant
      t.references :team
      t.datetime :cal_start
      t.datetime :cal_end

      t.timestamps
    end
    add_index :calendars, :tenant_id
    add_index :calendars, :team_id
  end
end
