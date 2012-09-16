require 'spec_helper'

describe Relationship do
  
  let(:user) { FactoryGirl.create(:user, username: 'name', id: 1) }
  let(:contact) { FactoryGirl.create(:user, username: 'altname', id: 2) }
  let(:requesting) { Relationship.create(user_id:user.id,
    contact_id:contact.id) }
  let(:receiving) { requesting.partner }
  
  it 'should return only contact id and approved status with to_json' do
    requesting.to_json.should include("approved")
    requesting.to_json.should include("contact_id")
    requesting.to_json.should_not include("user_id")
  end
  
  describe 'sending a new contact request' do

    it 'both relationships should be saved' do
      requesting.should_not be_new_record
      receiving.should_not be_new_record
    end
    
    it 'should contain the id of its partner relationship' do
      requesting.partner_id.should == receiving.id
    end
    
  end
  
  describe 'approving a contact request' do
      
      it 'should succeed along with its partner if called on the receiver' do
        receiving.accept
        requesting.reload; receiving.reload
        
        receiving.approved.should == :true.to_s
        requesting.approved.should == :true.to_s
      end
      
      it 'should raise an unauthorized exception if called on relationship which requested it' do
        expect { requesting.accept }
          .to raise_error(Relationship::UnauthorizedError)
      end
  end
  
  describe 'deleting a relationship' do
    it 'should delete the partner relationship as well' do
      receiving = requesting.partner
      requesting.destroy
      Relationship.exists?(requesting.id).should == false
      Relationship.exists?(receiving.id).should == false
    end
  end
  
  describe 'disconnecting a relationship' do
    it 'should mark both relationships approved status to false' do
      requesting.disconnect
      requesting.approved.should == :false
      receiving.approved.should == :false
    end
  end
end