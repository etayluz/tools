class MoveEmailColumn < ActiveRecord::Migration
  def up
  	  change_column :apps, :email, :string, before: :website

  end
end
