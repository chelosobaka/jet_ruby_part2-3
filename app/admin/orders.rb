ActiveAdmin.register Order do
  permit_params :weight, :length, :width, :height, :origins, :destinations, :status
  includes :user

  action_item :complete, only: :show do
    link_to 'Complete', complete_admin_order_path(order), method: :patch if order.processing?
  end

  index do
    selectable_column
    id_column
    column(:first_name) {|order| order.user.first_name }
    column(:second_name) {|order| order.user.second_name }
    column(:patronymic) {|order| order.user.patronymic }
    column(:phone_number) {|order| order.user.phone_number }
    column(:email) {|order| order.user.email }
    column :weight
    column :length
    column :width
    column :height
    column :origins
    column :destinations
    column :status

    column :actions do |order|
      div class: "button-group" do
        links = []
        links << link_to('complete', complete_admin_order_path(order), method: :patch) if order.processing?
        links << link_to('show', admin_order_path(order))
        links << link_to('delete', admin_order_path(order), method: :delete)
        safe_join(links, " ")
      end
    end
  end

  filter :weight
  filter :length
  filter :width
  filter :height
  filter :origins
  filter :destinations
  filter :status

  member_action :complete, method: :patch do
    resource.complete!
    redirect_to admin_orders_path, notice: "Completed!"
  end
end
