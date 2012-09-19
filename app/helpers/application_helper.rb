module ApplicationHelper
  def self.send_notification(notification)
    @notification = notification
    build_request
    send_request
    
    return {:code => @resp.code.to_i, :message => @dat }
  end
  
  def self.build_request
    @url = URI.parse 'https://android.googleapis.com/gcm/send'
    
    @headers = {"Content-Type" => "application/json",
             "Authorization" => "key=AIzaSyBUU07B9fhSq-WNLbyYYDakhILDonM-OzE"}

    @data = @notification.data.merge({:collapse_key => @notification.collapse_key}) unless @notification.collapse_key.nil?
    @data = @data.merge({:delay_while_idle => @notification.delay_while_idle}) unless @notification.delay_while_idle.nil?
    @data = @data.merge({:time_to_live => @notification.time_to_live}) unless @notification.time_to_live.nil?
    @data = @data.to_json
  end
  
  def self.send_request
    http = Net::HTTP.new(@url.host, @url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    @resp, @dat = http.post(@url.path, @data, @headers)
  end
end
