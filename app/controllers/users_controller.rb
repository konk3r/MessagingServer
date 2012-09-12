class UsersController < ApplicationController
  
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
    if !authenticated_as_current_user
      return render :status => :unauthorized,
       :json => {:error => "Must be signed in as user to delete it"}
    end
    
    current_user.destroy
    render :json => current_user  
  end
  
  def authenticated_as_current_user
    authenticated_as_current_user = current_user &&
      ( params[:username] == current_user.username )
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