class User < ActiveRecord::Base
  attr_accessible :username, :password, :first_name, :last_name
  validates :username, :presence => true
  validates :password, :presence => true
  validates_uniqueness_of :username
  
  def as_mobile_request_json
    as_json(:only => [:username, :created_at], :methods => "name")
  end
  
  def name
    self.first_name ||= ""
    self.last_name ||= ""
    self.first_name + " " + self.last_name
  end
end
