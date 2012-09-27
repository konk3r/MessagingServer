class Message < ActiveRecord::Base
  belongs_to :user_from, :class_name => "User", :foreign_key => "receiver_id"
  belongs_to :user_to, :class_name => "User", :foreign_key => "sender_id"
  attr_accessible :sent_at, :received_at, :text, :deleted,
    :sender_id, :receiver_id, :private, :message_type
  
  validates_presence_of :sender_id
  validates_presence_of :receiver_id
  validates_presence_of :text
  validates_presence_of :sent_at
  validates_presence_of :message_type
  validate :sender_exists
  validate :receiver_exists
  
  scope :conversation_between, lambda { |user_a, user_b| where(
    '(sender_id =? AND receiver_id =?) OR (sender_id =? AND receiver_id =?)',
    user_a.id, user_b.id, user_b.id, user_a.id).order('sent_at DESC') }
  
  def sender_exists
    if self.sender_id && !User.exists?(self.sender_id)
      errors.add(:sender_id, 'sender must exist in database')
    end
  end
  
  def receiver_exists
    if self.receiver_id && !User.exists?(self.receiver_id)
      errors.add(:receiver_id, "receiver must exist in database")
    end
  end

  def self.create_from_external_request(params)
    @params = params
    convert_param_keys_to_symbols
    filter_params
    message = Message.create(@params)
  end
  
  def self.convert_param_keys_to_symbols
    @params = Hash[
      @params.map {|key, value| [key.to_sym, value]}
      ]
  end
  
  def self.filter_params
    allowed_params = [:sender_id, :receiver_id, :sent_at, :text, :message_type]
    @params.select! { |k, v| allowed_params.include? k }
  end
  
  def as_json(params = nil)
    super.as_json(:only => 
      ["deleted", "id", "private", "receiver_id", "sender_id", "text", "sent_at", "message_type"])
  end
end