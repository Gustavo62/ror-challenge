class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string  :description
      t.integer :stock
      t.float   :price 
      t.integer :cod_bars
      t.bollean :active

      t.timestamps
    end
  end
end
