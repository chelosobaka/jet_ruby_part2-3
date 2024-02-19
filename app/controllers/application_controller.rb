class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name second_name patronymic phone_number
                                                         avatar_cache avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name second_name patronymic phone_number
                                                                avatar_cache avatar])
  end
end
