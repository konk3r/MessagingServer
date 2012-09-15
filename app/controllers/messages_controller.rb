class MessagesController < ApplicationController
  before_filter :authenticate_user
  before_filter :authorize_user
  before_filter :verify_contacts, :only => [:create, :show]
  
  def create
    build_request_parameters
    message = Message.create_from_external_request(@message_params)
    if message.new_record?
      render :status => :bad_request, :json => 
        {:error => "Could not create message with given parameters"}
    else
      render :status => :created, :json => message
    end
  end

  def show
    conversation = Message.conversation_between(@current_user, self.contact)
    render :status => :ok, :json => conversation
  end

  def update
  end
  
  def destroy
  end

  def authorize_user
    if @current_user.id.to_s != params[:id]
      puts "current user not matching params"
      return render :status => :forbidden, :json => {:error =>
        'Must be signed in as user to make request from it'}
    end
  end
  
  def verify_contacts
    if !User.exists?(params[:contact_id])
      render :status => :not_found,
        :json => {:error => "resource not found"} and return
    end
    
    if !@current_user.contacts_with(self.contact)
      puts "current user not contacts with contact"
      render :status => :forbidden, :json => {:error => 
          "Must be contacts with user to perform this action"} and return
    end
  end
  
  def build_request_parameters
    sender_id = {sender_id: params[:id], receiver_id: params[:contact_id]}
    @message_params = JSON.parse(params[:message_json])
    @message_params.merge!(sender_id)
  end
  
  def contact
    @contact ||= User.find_by_id(params[:contact_id])
  end
end