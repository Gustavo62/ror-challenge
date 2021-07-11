class CreateStocks < ActiveRecord::Migration[6.1]
  def change
    create_table :stocks do |t|
      t.integer :number_order
      t.float :deliver_fee
      t.float :total_price  
      t.string :origin

      t.timestamps
    end
  end
end
