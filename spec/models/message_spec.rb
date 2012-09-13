require 'spec_helper'

describe Message do
  before :all do
    @sender_id = 0
    @receiver_id = 1
    @time = Time.zone.now
    @text = 'I miss you'
  end
  
  describe 'creating a message' do
    describe 'Invalid User' do
      
      it 'should not create a message if sender is not sent' do
        User.should_receive(:exists?).with(@receiver_id).and_return true
        params = {:receiver_id => @receiver_id, :text => @text,
          :sent_time => @time}
        message = Message.create_from_external_request(params)
        message.should be_new_record if message
      end
      
      it 'should not create a message if sender is not in database' do
        User.should_receive(:exists?).with(@sender_id).and_return false
        User.should_receive(:exists?).with(@receiver_id).and_return true
        params = {:sender_id => @sender_id, :receiver_id => @receiver_id,
          :text => @text, :sent_time => @time}
        message = Message.create_from_external_request(params)
        message.should be_new_record if message
      end
      
      it 'should not create a message if receiver is not sent' do
      User.should_receive(:exists?).with(@sender_id).and_return true
        params = {:sender_id => @sender_id, :text => @text,
          :sent_time => @time}
        message = Message.create_from_external_request(params)
        message.should be_new_record if message
      end
      
      it 'should not create a message if receiver is not in database' do
        User.should_receive(:exists?).with(@sender_id).and_return true
        User.should_receive(:exists?).with(@receiver_id).and_return false
        params = {:sender_id => @sender_id, :receiver_id => @receiver_id,
          :text => @text, :sent_time => @time}
        message = Message.create_from_external_request(params)
        message.should be_new_record if message
      end
      
    end
    
    describe 'Invalid parameters' do
      
      it 'should not create a message without a sent time' do
        params = {:sender_id => @sender_id, :receiver_id => @receiver_id,
          :text => @text}
        message = Message.create_from_external_request(params)
        message.should be_new_record if message
      end
      
      it 'should not create a message without text' do
        params = {:sender_id => @sender_id, :receiver_id => @receiver_id,
          :sent_time => @time}
        message = Message.create_from_external_request(params)
        message.should be_new_record if message
      end

      it 'should not create a message without text' do
        params = {:sender_id => @sender_id, :receiver_id => @receiver_id,
          :sent_time => @time}
        message = Message.create_from_external_request(params)
        message.should be_new_record if message
      end
      
      it 'should strip extra parameters from a request' do
        User.should_receive(:exists?).with(@sender_id).and_return true
        User.should_receive(:exists?).with(@receiver_id).and_return true
        
        params = {:sender_id => @sender_id, :receiver_id => @receiver_id,
          :text => @text, :sent_time => @time, :deleted => true}
        message = Message.create_from_external_request(params)
        message.deleted.should == nil
      end
      
    end
    
    describe 'Successful message' do
      before :each do
        User.should_receive(:exists?).with(@sender_id).and_return true
        User.should_receive(:exists?).with(@receiver_id).and_return true
        
        params = {:sender_id => @sender_id, :receiver_id => @receiver_id,
          :text => @text, :sent_time => @time}
        @message = Message.create_from_external_request(params)
      end
      
      it 'should return a stored message' do
        @message.should_not be_new_record
      end
      it 'should contain the time it was created with' do
        @time.should == @message.sent_time
      end
      it 'should contain the text it was created with' do
        @message.text.should == @text
      end
      it 'should contain the id of the sender' do
        @message.sender_id.should == @sender_id
      end
      it 'should contain the id of the reciever' do
        @message.receiver_id.should == @receiver_id
      end
    end
  end
end