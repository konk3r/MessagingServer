class Relationship < ActiveRecord::Base
  attr_accessible :contact_id, :approved
  
  belongs_to :user
  belongs_to :contact, class_name: "User"
  after_destroy :destroy_partner
  
  def destroy_partner
    if Relationship.exists?(self.partner_id)
      Relationship.find(self.partner_id).destroy
    end
  end
  
  def self.create_contact_request(from_user, to_user)
    @requesting_relationship = from_user.relationships
      .build(contact_id:to_user.id, approved: :pending_partner_action)
    @receiving_relationship = to_user.relationships
      .build(contact_id:from_user.id, approved: :response_requested)
    
    @requesting_relationship.save
    @receiving_relationship.save
    
    self.share_partner_ids
    
    return @requesting_relationship, @receiving_relationship
  end
  
  def self.share_partner_ids
    @requesting_relationship.partner_id =
      @receiving_relationship.id 
    @receiving_relationship.partner_id =
      @requesting_relationship.id
    
    @requesting_relationship.save
    @receiving_relationship.save
  end
  
  def accept
    partner_must_approve = (approved.to_s == :pending_partner_action.to_s)
    if partner_must_approve
      raise UnauthorizedError, 
        "User which created contact request cannot be the one to approve it"
    end
    
    load_partner
    
    self.approved = :true; @partner.approved = :true
    self.save && @partner.save
  end
  
  def load_partner
    @partner = Relationship.find_by_id(partner_id)
  end
  
  class UnauthorizedError < Error
  end
  
end
