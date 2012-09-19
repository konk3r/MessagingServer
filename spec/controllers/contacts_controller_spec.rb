require 'spec_helper'

describe ContactsController do
  let(:user) { FactoryGirl.build :user, username: :user, id:1}
  let(:contact) { FactoryGirl.build :user, username: :contact, id:2,
    :device_id => 'APA91bGEwprdPe-vGbhHEbkm1i9PfzC9DG71DpSXX8OdzVmbR0jNjaVprhaGoCRJUO-Tk9UBHFWN-y-P4RQaMVd0v-YQcAMtJ2xlldCDAYnywXgSmI1wwgrY_Mlct95TA7dihHJKth5NsNiIMuAq1m1SQHGa2xhg_nkUSHyn-TIIXMoyz3OwEss'}
  
  before :each do
    User.should_receive(:find_by_id).with(nil).and_return(user)
  end
  
  describe 'when properly authenticated' do
    before :each do
      User.should_receive(:exists?).at_least(0).times.and_return(true)
    end
    
    it 'should return 200 and a list of all valid and pending contacts' do
      get :show, id: user.id
      contacts = JSON.parse response.body
      
      contacts.should_not == nil
      response.status.should == 200
    end
    
    describe 'Requests with specific contacts' do
    
      it 'should create a contact request' do
        User.should_receive(:find_by_username).with(contact.username.to_s)
          .at_least(1).times.and_return(contact)
        post :create, id: user.id, contact_username: contact.username
        response.status.should == 200
      end
      
      it 'should sent the request to the user' do
        User.should_receive(:find_by_username).with(contact.username.to_s)
          .at_least(1).times.and_return(contact)
        post :create, id: user.id, contact_username: contact.username
        
      end
  
      it 'should accept contact request' do
        User.should_receive(:find_by_id).with(contact.id.to_s)
          .at_least(1).times.and_return(contact)
        contact.add_contact(user)
        put :update, id: user.id, contact_id: contact.id, accept:true
        response.status.should == 200
      end
  
      it 'should return error if the wrong user accepts contact request' do
        User.should_receive(:find_by_id).with(contact.id.to_s)
          .at_least(1).times.and_return(contact)
        user.add_contact(contact)
        put :update, id: user.id, contact_id: contact.id, accept:true
        response.status.should == 403
      end
  
      it 'should delete contacts' do
        User.should_receive(:find_by_id).with(contact.id.to_s)
          .at_least(1).times.and_return(contact)
        user.add_contact(contact)
        delete :destroy, id: user.id, contact_id: contact.id
        response.status.should == 200
      end
    end
  end
  
  it 'should return 404 if the contact does not exist' do
    post :create, id: user.id, contact_username: contact.username
    response.status.should == 404
  end
  
  it 'should return 403 if not authenticated as the requested user' do
      post :create, id: contact.id, contact_username: user.username
      response.status.should == 403
  end
end