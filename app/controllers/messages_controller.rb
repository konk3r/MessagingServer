class MessagesController < ApplicationController
  before_filter :authenticate_user
  def create
    if @current_user.id.to_s != params[:id]
      return render :status => :forbidden, :json => {:error =>
        'Must be signed in as user to send message from it'}
    end
    
    build_request_parameters
    message = Message.create_from_external_request(@message_params)
    if message.new_record?
      render :status => :bad_request, :json => 
        {:error => "Could not create message with given parameters"}
    else
      render :status => :created, :json => message
    end
  end

  def update
  end
  
  def destroy
  end
  
  def build_request_parameters
    sender_id = {:sender_id => params[:id]}
    @message_params = JSON.parse(params[:message_json])
    @message_params.merge!(sender_id)
  end
end
