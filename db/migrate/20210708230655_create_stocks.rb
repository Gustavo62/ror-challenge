class CreateStocks < ActiveRecord::Migration[6.1]
  def change
    create_table :stocks do |t|
      t.integer :number_order
      t.float :deliver_fee
      t.float :total_price
      t.references :product_id, null: false, foreign_key: true
      t.int :amount

      t.timestamps
    end
  end
end
