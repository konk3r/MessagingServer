require 'spec_helper'

describe MessagesController do
  describe 'Sending a message' do
    before :each do
      @sender_id, @receiver_id, @alt_id = 1, 2, 3
      @time, @text = Time.zone.now, "message text"
      @user = FactoryGirl.build(:user, :id => @sender_id)
      @params = {"receiver_id" => @receiver_id, "sent_at" => @time,
        "text" => @text}
    end
    
    describe 'checking authentication' do

        it 'should fail with a 401 if user is not authenticated' do
          User.should_receive(:find_by_id).and_return(nil)
          post :create, :id => @user.id, :message_json => @params.to_json
          response.status.should == 401
        end
        
        it 'should fail with a 403 if sending user is not authenticated' do
          User.should_receive(:find_by_id).and_return(@user)
          post :create, :id => @alt_id, :message_json => @params.to_json
          response.status.should == 403
        end
    end
    
    describe 'response' do
      before :each do
        User.should_receive(:find_by_id).and_return(@user)
      end
      describe 'if successful' do
        before :each do
          User.should_receive(:exists?).with(@sender_id).and_return true
          User.should_receive(:exists?).with(@receiver_id).and_return true
        
          post :create, :id => @user.id, :message_json => @params.to_json
          @body = JSON.parse(response.body)
        end
      
        it 'should return 201' do
          response.status.should == 201
        end
      
        it 'should contain the sender id it was created with' do
          (@body.should include "sender_id" ) &&
            @body["sender_id"].should == @sender_id
        end
      
        it 'should contain the receiver id it was created with' do
          (@body.should include "receiver_id" ) &&
            @body["receiver_id"].should == @receiver_id
        end
        
        it 'should contain the text it was created with' do
          (@body.should include "text" ) &&
            @body["text"].should == @text
        end
        
        it 'should contain the sent time it was created with' do
          old_time = Date.parse(@time.to_s)
          new_time = Date.parse(@body["sent_at"])
          (@body.should include "sent_at" ) &&
            new_time.should ==  old_time
        end
        
      end
      
      it "should fail with a 400 error if the message couldn't be created" do
        message = FactoryGirl.build(:message)
        message.should_receive(:new_record?).and_return(true)
        Message.should_receive(:create_from_external_request).and_return(message)
        
        post :create, :id => @user.id, :message_json => @params.to_json
        response.status.should == 400
      end
    end
  end
  
  describe 'Loading conversation' do
    before :each do
      @user_id, @contact_id = 0, 1
    end
    
    it 'should fail with a 401 if user is not authenticated' do
      post :show, :id => @user_id, :contact_id => @contact_id
      response.status.should == 401
    end
    
    describe 'when authenticated' do
      before :each do
        user = FactoryGirl.build(:user, :id => @user_id)
        @contact = FactoryGirl.build(:user, :id => @contact_id)
        User.should_receive(:find_by_id).and_return(user)
      end
      
      it 'should return a 200 and the messages as valid json' do
        User.should_receive(:find_by_id).and_return(@contact)
        User.should_receive(:exists?).with(@contact_id.to_s).and_return(true)
        post :show, :id => @user_id, :contact_id => @contact_id
        JSON.parse(response.body)
      end
    
      it 'should return a 404 if the secondary user does not exist' do
        User.should_receive(:exists?).with(@contact_id.to_s).and_return(false)
        post :show, :id => @user_id, :contact_id => @contact_id
      
        response.status.should == 404
      end
    end
  end
  
  describe 'Updating a message' do
    
  end
end