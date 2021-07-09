class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string  :description
      t.integer :stock
      t.float   :price 
      t.string :cod_bars
      t.boolean :active

      t.timestamps
    end
  end
end
