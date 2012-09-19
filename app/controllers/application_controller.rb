class ApplicationController < ActionController::Base
  before_filter :set_current_user
  
  private 
  
  def set_current_user
    user = User.find_by_id(params[:user_id])
    if user && user.api_key != nil && user.api_key == params[:api_key]
      @current_user = user
    end
  end
  
  def authenticate_user
    if !@current_user
      render :status => :unauthorized, 
        :json => {:error => "Must be signed in to perform this action"}
    end
  end
end
