class TextEmail < ActiveRecord::Migration
  def change
    change_column :websites, :email, :text
  end
end
