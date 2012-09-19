class DevicesController < ApplicationController
  before_filter :authenticate_user
  
  def create
    @current_user.add_device(params[:device_id])
    render :json => @current_user
  end
  
  def destroy
    @current_user.remove_device(params[:device_id])
    if @current_user.device_id == nil
      render :json => @current_user
    else
      render :json => {:error => "failed to remove device"}
    end
  end

end