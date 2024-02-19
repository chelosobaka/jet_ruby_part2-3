class RemoveAttributesFromOrder < ActiveRecord::Migration[7.0]
  def change
    remove_column :orders, :first_name, :string
    remove_column :orders, :second_name, :string
    remove_column :orders, :patronymic, :string
    remove_column :orders, :phone_number, :text
    remove_column :orders, :email, :text
  end
end
