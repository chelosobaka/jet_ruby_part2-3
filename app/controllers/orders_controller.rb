class OrdersController < ApplicationController
  before_action :set_order, only: %i[show]
  before_action :set_user

  def index
    @order_attr_list = { 'created date' => 'created_at', 'price' => 'price', 'distance' => 'distance' }
    @order_type_list = { 'decreasing' => 'DESC', 'increasing' => 'ASC' }

    @orders = @user.orders.order("#{params[:order_attr]} #{params[:order_type]}").page(params[:page]).per(10)
  end

  def show; end

  def new
    @order = @user.orders.build
  end

  def create
    @order = @user.orders.build(order_params)

    if @order.save
      redirect_to user_order_path(user_id: @order.user.id, id: @order.id), notice: 'Order was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def set_user
    @user = current_user
  end

  def order_params
    params.require(:order).permit(:user_id, :weight, :length, :width, :height, :origins, :destinations)
  end
end
