class CreatePromotions < ActiveRecord::Migration[6.1]
  def change
    create_table :promotions do |t|
      t.string :name
      t.string :description
      t.boolean :active
      t.integer :min_amount
      
      t.timestamps
    end
  end
end
