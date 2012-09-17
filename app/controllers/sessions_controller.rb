class SessionsController < ApplicationController
  def create
    user = User.find_by_username(params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      render :status => :ok, :json => user
    else
      render :status => :unauthorized, :json => user_not_logged_in
    end
  end

  def destroy
    session[:user_id] = nil
    render :json => user_logged_out
  end
  
  def user_not_logged_in
    reply = {:error => "user not logged in"}
  end
  
  def user_logged_out
    reply = {:success => "user logged out succesfully"}
  end
end