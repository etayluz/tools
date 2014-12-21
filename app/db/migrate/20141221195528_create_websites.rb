class CreateWebsites < ActiveRecord::Migration
  def change
    create_table :websites do |t|
      t.string :website
      t.integer :apps
      t.string :email

      t.timestamps
    end
  end
end
