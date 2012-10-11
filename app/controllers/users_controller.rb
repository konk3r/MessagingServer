class UsersController < ApplicationController
  before_filter :authenticate_user, :only => :destroy
  before_filter :filter_params, :only => :create
  before_filter :load_image, :only => :update
  
  def create
    @current_user = User.create(@params)
      
    setup_create_response
    if @current_user.valid?
      render :json => @current_user
    else
      render :json => @error
    end
  end
  
  def update
    file_params = params.select { |name,value| value.is_a?(File) || value.is_a?(Tempfile) }
    json = { :file_size => file_params.size}
    render :json => json and return

    update_user_params
    
    setup_update_response
    if @current_user.valid?
      render :json => @current_user
    else
      render :json => @error
    end
  end
  
  def destroy
    @current_user.destroy
    render :json => {:status => "User successfully deleted"}
  end
  
  protected
  
  def update_user_params
    @current_user.set_photo @image if @image
    
    @current_user.first_name = params[:first_name] if params.include? :first_name
    @current_user.last_name = params[:last_name] if params.include? :last_name
    if params.include? :status
      @current_user.status = params[:status]
      @current_user.status_updated_at = Time.zone.now
    end
    
    if params.include? :password and params.include? :new_password
      password = params[:password]
      new_password = params[:new_password]
      @current_user.password = new_password if @current_user.authenticate(password)
    end
    
    @current_user.save
  end
  
  def setup_create_response
    if @current_user.valid?
      return response.status = :created
    elsif is_duplicate_user
      @error = {:error => "user already exists" }
      return response.status = :conflict
    else
      @error = {:error => "could not create user" }
      response.status = :bad_request
    end
  end
  
  
  def setup_update_response
    if @current_user.valid?
      return response.status = :ok
    else
      @error = {:error => "could not update user" }
      response.status = :bad_request
    end
  end
  
  def is_duplicate_user
    if @current_user.errors.include? :username
      return true if @current_user.errors[:username].include? "has already been taken"
    end
    return false
  end
  
  def filter_params
    allowed_params = ["username", "password", "first_name", "last_name"]
    @params = params.select {|k, v| allowed_params.include? k}
  end
  
  def load_image
    if params.include? :image and params.include? :image_content_type
      @image = params[:image] if params[:image_content_type] == 'image/jpeg'
    end
  end
  
end