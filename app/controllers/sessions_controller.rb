class SessionsController < ApplicationController
  before_filter :authenticate_user, :only => :destroy
  
  def create
    user = User.find_by_username(params[:username])
    if user && user.authenticate(params[:password])
      user.generate_api_key!
      render :status => :ok, :json => user.with_api_key
    else
      render :status => :unauthorized, :json => {:error => "user not logged in"}
    end
  end

  def destroy
    @current_user.remove_api_key!(params[:api_key])
    @current_user.remove_device!(params[:device_id])
    render :json => {:success => "user logged out succesfully"}
  end
  
end