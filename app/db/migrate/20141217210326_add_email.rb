class AddEmail < ActiveRecord::Migration
  def change
  	add_column :apps, :email, :string, after: :website
  end
end
