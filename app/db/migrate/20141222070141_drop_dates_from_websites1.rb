class DropDatesFromWebsites1 < ActiveRecord::Migration
  def change
  	remove_column :websites, :created_at
  	remove_column :websites, :updated_at
  end
end
