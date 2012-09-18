class ContactsController < ApplicationController
  before_filter :authenticate_user
  before_filter :authorize_user
  before_filter :verify_contact, :only => [:create, :update, :destroy]
  
  def create
    connection = @current_user.add_contact(@contact)
    render :json => connection
  end
  
  def show
    render :json => @current_user.contacts
  end

  def update
    if params[:accept] && params[:accept] == true
      begin
        contact = @current_user.accept_contact(@contact)
        render :json => contact
      rescue Relationship::UnauthorizedError => error
        render status: :forbidden, :json => {:error => error.message}
      end
    end
  end

  def destroy
    removed_connection = @current_user.remove_contact(@contact)
    render :json => removed_connection
  end
  
  def authorize_user
    if @current_user.id.to_s != params[:id]
      return render :status => :forbidden, :json => {:error =>
        'Must be signed in as user to make request from it'}
    end
  end
  
  def verify_contact
    load_contact
    if !@contact
      render :status => :not_found,
        :json => {:error => "Contact not found"} and return
    end
  end
  
  def load_contact
    if params[:contact_id]
      @contact = User.find_by_id(params[:contact_id])
    elsif params[:contact_username]
      @contact = User.find_by_username(params[:contact_username]) 
    end
  end
end
