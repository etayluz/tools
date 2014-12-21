class DropDates < ActiveRecord::Migration
  def change
  	remove_column :apps, :created_at
  	remove_column :apps, :updated_at
  end
end
