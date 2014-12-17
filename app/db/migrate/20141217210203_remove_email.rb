class RemoveEmail < ActiveRecord::Migration
  def change
  	remove_column :apps, :email
  end
end
