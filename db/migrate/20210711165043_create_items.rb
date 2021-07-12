class CreateItems < ActiveRecord::Migration[6.1]
  def change
    create_table :items do |t|
      t.references :product, null: false, foreign_key: true
      t.references :stock, null: true, foreign_key: true
      t.integer :amount
      t.float :price
      t.boolean :promotion
      t.integer :promotion_amount

      t.timestamps
    end
  end
end
