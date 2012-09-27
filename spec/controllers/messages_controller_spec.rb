require 'spec_helper'

describe MessagesController do
  let(:user_id) { 1 }
  let(:contact_id) { 2 }
  let(:non_user_id) { 3 }
  let(:fake_api_key) { 'this seems wrong' }
  let(:api_key) { 'this is a randomly generated key, I promise' }
  let(:device_id) {'APA91bHlrzyjbLqE7oiC-I0ZIZ2ZdayU3vbEAMDYeP45ZcvuTf_-P3yqs9KxYgASFoOJzMzanRh6itt2QI-QoMLxfkRX5Eft39fl1cZT89uA76HUzDKx0pOarTg8FWu5IFt4xIgqXEG3tAuE3c8PI6bU5ApsbePzlEzkjYBSDAfisCHFB7UOJKA'}
  let(:time) { Time.zone.now }
  let(:text) { 'Message text' }
  let(:params) { {"sent_at" => time, "text" => text} }
  let(:user) { FactoryGirl.build(:user, id:user_id, api_key:api_key) }
  let(:message) { FactoryGirl.build(:message) }
  let(:contact) { 
    FactoryGirl.build(:user, id:contact_id, username: :contact, device_id: device_id) }
  
  describe 'Sending a message' do
    
    describe 'checking authentication' do
        it 'should fail with a 401 if user is not authenticated' do
          User.should_receive(:find_by_id).and_return(user)
          post :create, contact_id: contact_id,
            message_json: params.to_json, :user_id => user.id,
            :api_key => fake_api_key
          response.status.should == 401
        end
    end
    
    
    describe 'response' do
      before :each do
        User.should_receive(:find_by_id).and_return(user)
        User.should_receive(:find_by_id).with(contact.id.to_s).and_return(contact)
      end
      
      describe 'if successful' do
        before :each do
          User.should_receive(:exists?).at_least(1).times.and_return true
          user.should_receive(:contacts_with).and_return true
        
          post :create, contact_id: contact.id, sent_at: time, text: text,
            user_id: user.id, api_key: user.api_key, message_type: :text
          @body = JSON.parse(response.body)
        end
      
        it 'should return 201' do
          response.status.should == 201
        end
      
        it 'should contain the sender id it was created with' do
          (@body.should include "sender_id" ) &&
            @body["sender_id"].should == user.id
        end
      
        it 'should contain the receiver id it was created with' do
          (@body.should include "receiver_id" ) &&
            @body["receiver_id"].should == contact.id
        end
        
        it 'should contain the text it was created with' do
          (@body.should include "text" ) &&
            @body["text"].should == text
        end
        
        it 'should contain the sent time it was created with' do
          old_time = Date.parse(time.to_s)
          new_time = Date.parse(@body["sent_at"])
          (@body.should include "sent_at" ) &&
            new_time.should ==  old_time
        end
        
      end
      
      it "should fail with a 400 error if the message couldn't be created" do
        User.should_receive(:exists?).and_return true
        Message.should_receive(:create_from_external_request).and_return message
        message.should_receive(:new_record?).and_return true
        user.should_receive(:contacts_with).and_return true
        
        post :create, contact_id: contact.id, sent_at: time, text: text,
            user_id: user.id, api_key: user.api_key
        response.status.should == 400
      end
      
      it "should fail with a 403 error if the users aren't contacts" do
        User.should_receive(:exists?).at_least(1).times.and_return true
        
        post :create, contact_id: contact.id, sent_at: time, text: text,
            user_id: user.id, api_key: user.api_key
        response.status.should == 403
      end
    end
  end
  
  describe 'Loading conversation' do
    before :each do
      user.add_contact(contact)
      contact.accept_contact(user)
    end
    
    it 'should fail with a 401 if user is not authenticated' do
      get :show, :contact_id => contact_id, :user_id => user.id,
        :api_key => user.api_key
      response.status.should == 401
    end
    
    describe 'when authenticated' do
      before :each do
        User.should_receive(:find_by_id).and_return(user)
      end
      
      it 'should return a 200 and the messages as valid json' do
        User.should_receive(:find_by_id).and_return(contact)
        User.should_receive(:exists?).at_least(1).times.and_return(true)
        get :show, :contact_id => contact_id, :user_id => user.id,
          :api_key => user.api_key
        
        JSON.parse(response.body).should_not == nil
        response.status.should == 200
      end
    
      it 'should return a 404 if the secondary user does not exist' do
        User.should_receive(:exists?).with(contact_id.to_s).and_return(false)
        get :show, :contact_id => contact_id, :user_id => user.id,
          :api_key => user.api_key
      
        response.status.should == 404
      end
    end
  end
  
end