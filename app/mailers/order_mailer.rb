class OrderMailer < ApplicationMailer
  def order_info
    @order = Order.find(params[:order_id])
    @message = params[:message]
    mail(to: @order.user.email, subject: 'Transportation order')
  end
end
