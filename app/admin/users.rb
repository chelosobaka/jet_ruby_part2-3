ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :first_name
    column :second_name
    column :patronymic
    column :phone_number
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :first_name
  filter :second_name
  filter :patronymic
  filter :phone_number
  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs do
      f.input :first_name
      f.input :second_name
      f.input :patronymic
      f.input :phone_number
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

end
