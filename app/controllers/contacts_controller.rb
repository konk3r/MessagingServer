class ContactsController < ApplicationController
  before_filter :authenticate_user
  before_filter :verify_contact, :only => [:create, :update, :destroy]
  
  def create
    begin
      connection = @current_user.add_contact(@contact)
    rescue ActiveRecord::RecordNotUnique
      return render :status => 409, :json => {:error => "Users are already connected"}
    end
    send_notification contact_request, :contact_request
    render :json => connection
  end
  
  def show
    render :json => @current_user.relationships.where("approved <> ?", "false")
  end

  def update
    if params[:accept] && params[:accept] == "true"
      begin
        contact = @current_user.accept_contact(@contact)
        send_notification contact_accepted, :contact_accepted
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
  
  protected
  
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
  
  def send_notification(message_text, collapse_key = :standard)
    return if @contact.device_id == nil
    
    device = Gcm::Device.find_by_registration_id(@contact.device_id)
    if !device
      device = Gcm::Device.new(:registration_id => @contact.device_id)
    end
    notification = Gcm::Notification.new
    notification.device = device
    notification.collapse_key = collapse_key
    notification.delay_while_idle = false
    notification.data = {:registration_ids => [@contact.device_id], :data => 
      {:message_text => message_text.to_json}}
    
    ApplicationHelper::send_notification(notification)
  end
  
  def contact_request
    message = {:content =>
      {:username => @current_user.username,:name => @current_user.name}}
    type = {:type => :contact_request}
    return message.merge(type)
  end
  
  def contact_accepted
    message = {:content =>
      {:username => @current_user.username,:name => @current_user.name}}
    type = {:type => :contact_accepted}
    return message.merge(type)
  end
  
end
