class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_variables
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def set_variables
    last_week_clue = Clue.prev_week_last_clue(Date.today)
    if last_week_clue.nil?
      @history_week = Date.today.beginning_of_week - 7
    else
      @history_week = last_week_clue.week
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
