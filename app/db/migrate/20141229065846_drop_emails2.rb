class DropEmails2 < ActiveRecord::Migration
  def change
  	remove_column :apps, :email
  end
end
