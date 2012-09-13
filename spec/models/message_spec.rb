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
      before :each do
        @params = {:sent_time => @time, :text => @text}
      end
      
      it 'should not create a message if sender is not sent' do
        User.should_receive(:exists?).with(@receiver_id).and_return true
        message = Message.create(:receiver_id => @receiver_id, :text => @text, :sent_time => @time)
        message.should be_new_record
      end
      
      it 'should not create a message if sender is not in database' do
        User.should_receive(:exists?).with(@sender_id).and_return false
        User.should_receive(:exists?).with(@receiver_id).and_return true
        message = Message.create(:sender_id => @sender_id, :receiver_id => @receiver_id, :text => @text, :sent_time => @time)
        message.should be_new_record
      end
      
      it 'should not create a message if receiver is not sent' do
        User.should_receive(:exists?).with(@sender_id).and_return true
        message = Message.create(:sender_id => @sender_id, :text => @text, :sent_time => @time)
        message.should be_new_record
      end
      
      it 'should not create a message if receiver is not in database' do
        User.should_receive(:exists?).with(@sender_id).and_return true
        User.should_receive(:exists?).with(@receiver_id).and_return false
        message = Message.create(:sender_id => @sender_id, :receiver_id => @receiver_id, :text => @text, :sent_time => @time)
        message.should be_new_record
      end
      
    end
    
    describe 'Invalid parameters' do
      before :each do
        User.should_receive(:exists?).with(@sender_id).and_return true
        User.should_receive(:exists?).with(@receiver_id).and_return true
      end
      
      it 'should not create a message without a sent time' do
        message = Message.create(:sender_id => @sender_id, :receiver_id => @receiver_id, :text => @text)
        message.should be_new_record
      end
      
      it 'should not create a message without text' do
        message = Message.create(:sender_id => @sender_id, :receiver_id => @receiver_id, :sent_time => @time)
        message.should be_new_record
      end
      
    end
    
    describe 'Successful message' do
      before :each do
        User.should_receive(:exists?).with(@sender_id).and_return true
        User.should_receive(:exists?).with(@receiver_id).and_return true
        @message = Message.create(:sender_id => @sender_id,
          :receiver_id => @receiver_id, :text => @text,
          :sent_time => @time)
        
      end
      
      it 'should return a stored message' do
        @message.should_not be_new_record
      end
      it 'should contain the time it was created with' do
        @message.sent_time.should == @time
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