ActiveAdmin.register Order do
  permit_params :first_name, :last_name, :patronymic, :phone_number, :email,
                :weight, :length, :width, :height, :origins, :destinations

  index do
    selectable_column
    id_column
    column :first_name
    column :second_name
    column :phone_number
    column :email
    column :weight
    column :length
    column :width
    column :height
    column :origins
    column :destinations
    actions
  end

  filter :first_name
  filter :second_name
  filter :phone_number
  filter :email
  filter :weight
  filter :length
  filter :width
  filter :height
  filter :origins
  filter :destinations

  form do |f|
    f.inputs 'Order Details' do
      f.input :first_name
      f.input :second_name
      f.input :patronymic
      f.input :phone_number
      f.input :email
      f.input :weight
      f.input :length
      f.input :width
      f.input :height
      f.input :origins
      f.input :destinations
    end
    f.actions
  end

end
