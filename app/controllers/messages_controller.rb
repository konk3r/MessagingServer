class MessagesController < ApplicationController
  before_filter :authenticate_user
  before_filter :verify_contact, :only => [:create, :show]
  
  def create
    build_request_parameters
    message = Message.create_from_external_request(@message_params)
    if message.new_record?
      render :status => :bad_request, :json => 
        {:error => "Could not create message with given parameters"}
    else
      send_notification new_message
      render :status => :created, :json => message
    end
  end

  def show
    conversation = Message.conversation_between(@current_user, self.contact)
    render :status => :ok, :json => conversation
  end

  def update
  end
  
  protected
  
  def verify_contact
    if !User.exists?(params[:contact_id])
      render :status => :not_found,
        :json => {:error => "resource not found"} and return
    end
    
    if !@current_user.contacts_with(self.contact)
      render :status => :forbidden, :json => {:error => 
          "Must be contacts with user to perform this action"} and return
    end
  end
  
  def build_request_parameters
    @message_params = {sender_id: params[:user_id], receiver_id: params[:contact_id],
      sent_at: params[:sent_at], text: params[:text], message_type: params[:message_type] }
  end
  
  def contact
    @contact ||= User.find_by_id(params[:contact_id])
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

  def new_message
    message = {:content =>
      {:id => @current_user.id}}
    type = {:type => :new_message}
    return message.merge(type)
  end
end