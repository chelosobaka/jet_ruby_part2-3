class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.float :weight
      t.float :length
      t.float :width
      t.float :height
      t.text :origins
      t.text :destinations
      t.integer :distance
      t.money :price

      t.string :first_name
      t.string :second_name
      t.string :patronymic
      t.string :phone_number
      t.string :email

      t.timestamps
    end
  end
end
