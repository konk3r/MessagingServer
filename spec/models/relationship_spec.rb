require 'spec_helper'

describe Relationship do
  
  let(:user) { FactoryGirl.create(:user, username: 'name', id: 1) }
  let(:contact) { FactoryGirl.create(:user, username: 'altname', id: 2) }
  
  describe 'accessible attributes' do
    it 'should not allow access to user_id' do
      expect do
        Relationship.new(user_id: user.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end
  describe 'sending a new contact request' do
    before :each do
      @requesting, @receiving = Relationship.create_contact_request(user, contact)
    end

    it 'both relationships should be saved' do
      @requesting.should_not be_new_record
      @receiving.should_not be_new_record
    end
    
    it 'should contain the id of its partner relationship' do
      @requesting.partner_id.should == @receiving.id
    end
    
  end
  
  describe 'approving a contact request' do
      before :each do
        @requesting, @receiving = Relationship.create_contact_request(user, contact)
      end
      
      it 'should succeed along with its partner if called on the receiver' do
        @receiving.accept
        @requesting.reload; @receiving.reload
        
        @receiving.approved.should == :true.to_s
        @requesting.approved.should == :true.to_s
      end
      
      it 'should raise an unauthorized exception if called on relationship which requested it' do
        expect { @requesting.accept }
          .to raise_error(Relationship::UnauthorizedError)
      end
  end
  
  describe 'deleting a relationship' do
    it 'should delete the partner relationship as well' do
      @requesting, @receiving = Relationship.create_contact_request(user, contact)
      @requesting.destroy
      Relationship.exists?(@requesting.id).should == false
      Relationship.exists?(@receiving.id).should == false
    end
  end
end