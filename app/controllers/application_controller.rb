class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :authenticate_me!

  def authenticate_me!
    # Skip auth if you are trying to log in
    if controller_name.downcase == "users"
      return true
    end
    authenticate_user!
  end

  def flash_message(type, text)
    flash[type] ||= []
    flash[type] << text
  end

end
