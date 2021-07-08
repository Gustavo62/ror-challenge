class CreatePromotions < ActiveRecord::Migration[6.1]
  def change
    create_table :promotions do |t|
      t.string :name
      t.string :description
      t.bollean :active

      t.timestamps
    end
  end
end
