class UpdatesController < ApplicationController
before_filter :authenticate_user

  def show
    @time = params[:updates_since]
    @time_of_update = Time.zone.now
    build_contact_updates
    build_message_updates
    render :json => merge_updates
  end
  
  def build_contact_updates
    @contact_updates = @current_user.relationships.where("updated_at >?", @time)
  end
  
  def build_message_updates
    @message_updates = @current_user.sent_messages.where("updated_at >?", @time)
    @message_updates += @current_user.received_messages.where("updated_at >?", @time)
  end
  
  def merge_updates
    updates = {}
    updates.merge!({contacts:@contact_updates}) if @contact_updates
    updates.merge!({messages:@message_updates}) if @message_updates
    updates.merge!({last_update:@time_of_update.strftime("%Y-%m-%d %H:%M:%S.%12N %z")})
  end
end
