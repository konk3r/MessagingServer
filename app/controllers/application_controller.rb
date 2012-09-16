class ApplicationController < ActionController::Base
  before_filter :set_current_user
  
  private 
  
  def set_current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end
  
  def authenticate_user
    if !@current_user
      render :status => :unauthorized, 
        :json => {:error => "Must be signed in to perform this action"}
    end
  end
end
