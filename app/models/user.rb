class User < ActiveRecord::Base
  has_secure_password

  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id'
  has_many :received_messages, class_name: 'Message', foreign_key: 'receiver_id'
  has_many :relationships, dependent: :destroy
  has_many :contacts, through: :relationships, source: :contact
  
  attr_accessible :username, :password, :first_name, :last_name, :device_id,
    :api_key, :current_photo
  
  validates_presence_of :username
  validates_presence_of :password, :on => :create
  validates_uniqueness_of :username
    
  def as_json(params = nil)
    return super(:only => [:username, :id, :first_name, :last_name]) unless current_photo
    
    super(:only => [:username, :id, :first_name, :last_name], :methods => "image_url")
  end

  def set_photo(image)
    return false unless image
    
    bucket = ImageHelper.profile_photo_bucket
    filename = ImageHelper.profile_photo_name self
    ImageHelper.put(bucket, filename, image)

    if self.current_photo == nil
      self.current_photo = 1
    else
      self.current_photo += 1
    end
    true
  end
  
  def image_url
    ImageHelper.build_photo_url(self)
  end
  
  def name
    self.first_name ||= ""
    self.last_name ||= ""
    self.first_name + " " + self.last_name
  end
  
  def with_session_details
    members = {:username => self.username, :first_name => self.first_name,
      :last_name => self.last_name, :id => self.id, :api_key => self.api_key,
      :last_update => self.current_time, :image_url => self.image_url}

    members.merge! ({ :image_url => self.image_url }) if self.current_photo

    return members
  end
  
  def generate_api_key!
    api_seed = Time.now, (1..10).map{ rand.to_s }
    self.api_key = secure_digest(api_seed)
    self.save
    return self.api_key
  end
  
  def remove_api_key!(api_key)
    self.api_key = nil and self.save if self.api_key == api_key
  end
  
  def contacts_with(contact)
    return self.relationships.where(contact_id:contact.id, approved: :true)
      .size == 1
  end

  def add_contact(contact)
    Relationship.create(user_id:self.id, contact_id:contact.id)
  end
  
  def accept_contact(contact)
    relationship = find_relationship(contact)
    relationship.accept
  end
  
  def remove_contact(contact)
    relationship = find_relationship(contact)
    relationship.disconnect
  end
  
  def add_device!(device_id)
    self.device_id= device_id
    self.save
  end
  
  def remove_device!(device_id)
    if self.device_id == device_id
      self.device_id = nil
      self.save
    end
  end
  
  def find_relationship(contact)
    self.relationships.where(contact_id: contact.id).first
  end
  
  protected

  def secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end
  
  def current_time
    Time.zone.now.strftime("%Y-%m-%d %H:%M:%S.%12N %z")
  end
    
end
