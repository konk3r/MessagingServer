class Message < ActiveRecord::Base
  belongs_to :user_from, :class_name => "User", :foreign_key => "receiver_id"
  belongs_to :user_to, :class_name => "User", :foreign_key => "sender_id"
  attr_accessible :sent_time, :received_time, :text, :deleted,
    :sender_id, :receiver_id
  
  validates_presence_of :sender_id
  validates_presence_of :receiver_id
  validates_presence_of :text
  validates_presence_of :sent_time
  validate :sender_exists
  validate :receiver_exists
  
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
  
  scope :conversation_between, lambda { |user_a, user_b| where(
    '(sender_id =? AND recipient_id =?) OR (sender_id =? AND recipient_id =?)',
    user_a.id, user_b.id, user_b.id, user_a.id).order('time_sent DESC') }

    def self.dispatch(sender, receiver, params)
      message = Message.create(:sender_id => sender.id, :receiver_id => receiver.id, :text => params[:text], :sent_time => params[:sent_time])
      message.new_record?
    end
end