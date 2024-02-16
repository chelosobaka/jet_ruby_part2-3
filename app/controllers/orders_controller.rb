class OrdersController < ApplicationController
  before_action :set_order, only: %i[show]

  def show; end

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)

    if @order.save
      redirect_to order_url(@order), notice: 'Order was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def order_params
    params.require(:order).permit(:first_name, :second_name, :patronymic, :phone_number, :email,
                                  :weight, :length, :width, :height, :origins, :destinations)
  end
end
