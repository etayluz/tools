class AddEmailToApps < ActiveRecord::Migration
  def change
    add_column :apps, :email, :string
  end
end
