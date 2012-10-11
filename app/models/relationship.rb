class Relationship < ActiveRecord::Base
  attr_accessible :user_id, :contact_id, :approved, :partner_id
  
  belongs_to :user
  belongs_to :contact, class_name: "User"
  after_create :create_partner
  after_destroy :destroy_partner
  
  def partner
    @partner ||= Relationship.find_by_id(partner_id)
  end
  
  def create_partner
    return if Relationship.exists?(self.partner_id)
    
    partner = Relationship.create(user_id:self.contact_id, contact_id:self.user_id,
      partner_id:self.id, approved: :response_requested)
    
    self.approved = :pending_partner_action
    self.partner_id = partner.id
    self.save
  end
  
  def destroy_partner
    if Relationship.exists?(self.partner_id)
      Relationship.find(self.partner_id).destroy
    end
  end
  
  def disconnect
    self.approved = :false
    partner.approved = :false
    
    self.save; partner.save
    return self
  end
  
  def accept
    partner_must_approve = (approved.to_s == :pending_partner_action.to_s)
    if partner_must_approve
      raise UnauthorizedError, 
        "User which created contact request cannot be the one to approve it"
    end
    
    self.approved = :true; self.partner.approved = :true
    self.save; self.partner.save
    return self
  end
  
  def as_json(params = nil)
    params = { id:self.contact_id, approved:self.approved,
      username:self.contact.username, name:self.contact.name }
    if self.contact.current_photo
      params.merge! { image_url:self.contact.image_url } 
    end
    return params.as_json
  end
  
  class UnauthorizedError < Error
  end
  
end
