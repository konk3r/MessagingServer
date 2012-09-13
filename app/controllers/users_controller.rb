class UsersController < ApplicationController
  before_filter :authenticate_user, :only => :destroy
  
  def create
    @user = User.create(:username => params[:username],
      :password => params[:password])
      
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
    render :json => @current_user  
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
  
end