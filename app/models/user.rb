class User < ActiveRecord::Base
  has_secure_password

  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id'
  has_many :received_messages, class_name: 'Message', foreign_key: 'receiver_id'
  has_many :relationships, dependent: :destroy
  has_many :contacts, through: :relationships, source: :contact
  
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

  def add_contact(contact)
    Relationship.create_contact_request(self, contact)
  end
  
  def accept_contact(contact)
    relationship = find_relationship(contact)
    relationship.accept
  end
  
  def remove_contact(contact)
    relationship = find_relationship(contact)
    relationship.destroy
  end
  
  def find_relationship(contact)
    self.relationships.where(contact_id: contact.id).first
  end
  
end
