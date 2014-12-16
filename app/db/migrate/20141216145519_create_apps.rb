class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :name
      t.string :iTunes
      t.string :website

      t.timestamps
    end
  end
end
