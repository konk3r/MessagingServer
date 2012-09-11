class UsersController < ApplicationController
  
  def create
    @user = User.create(:username => params[:username],
      :password => params[:password])
    render :json => @user.as_mobile_request_json
  end
  
end