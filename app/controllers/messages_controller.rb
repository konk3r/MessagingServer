class MessagesController < ApplicationController
  before_filter :authenticate_user
  before_filter :authorize_user, :only => [:create, :show]
  
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
    if !User.exists?(params[:contact_id])
      render :status => :not_found,
        :json => {:error => "resource not found"} and return
    end
    
    contact = User.find_by_id(params[:contact_id])
    conversation = Message.conversation_between(@current_user, contact)
    render :status => :ok, :json => conversation
  end

  def update
  end
  
  def destroy
  end

  def authorize_user
    if @current_user.id.to_s != params[:id]
      return render :status => :forbidden, :json => {:error =>
        'Must be signed in as user to make request from it'}
    end
  end
  
  def build_request_parameters
    sender_id = {:sender_id => params[:id]}
    @message_params = JSON.parse(params[:message_json])
    @message_params.merge!(sender_id)
  end
end