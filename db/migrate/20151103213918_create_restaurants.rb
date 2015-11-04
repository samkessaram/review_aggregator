class CreateRestaurants < ActiveRecord::Migration
  def change
    create_table :restaurants do |t|
      t.string :name
      t.string :address
      t.integer :price_range
      t.string :cuisine

      t.timestamps null: false
    end
  end
end
