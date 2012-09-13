class User < ActiveRecord::Base
  has_secure_password
  has_many :sent_messages, :class_name => "Message", :foreign_key => 'sender_id'
  has_many :received_messages, :class_name => "Message", :foreign_key => 'receiver_id'
  attr_accessible :username, :password, :first_name, :last_name
  validates_presence_of :username
  validates_presence_of :password, :on => :create
  validates_uniqueness_of :username
  
  def as_json(params = nil)
    super(:only => [:username, :created_at], :methods => "name")
  end
  
  def name
    self.first_name ||= ""
    self.last_name ||= ""
    self.first_name + " " + self.last_name
  end
end
