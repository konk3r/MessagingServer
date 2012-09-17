class UsersController < ApplicationController
  before_filter :authenticate_user, :only => :destroy
  before_filter :filter_params, :only => :create
  
  def create
    @user = User.create(params)
      
    set_response_status_and_error_message
    if @user.valid?
      render :json => @user
    else
      render :json => @error
    end
  end
  
  def destroy
    if params[:username] != @current_user.username
      return render :status => :forbidden,
       :json => {:error => "Must be signed in as user to delete it"}
    end
    
    @current_user.destroy
    render :json => {:status => "User successfully deleted"}
  end
  
  def set_response_status_and_error_message
    if @user.valid?
      return response.status = :created
    elsif is_duplicate_user
      @error = {:error => "user already exists" }
      return response.status = :conflict
    else
      @error = {:error => "could not create user" }
      response.status = :bad_request
    end
  end
  
  def is_duplicate_user
    if @user.errors.include? :username
      if @user.errors[:username].include? "has already been taken"
        return true
      end
    end
    return false
  end
  
  def filter_params
    allowed_params = ["username", "password", "first_name", "last_name"]
    params.select! {|k, v| allowed_params.include? k}
  end
  
end