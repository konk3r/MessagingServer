require 'spec_helper'

  
describe UpdatesController do
  
  let(:api_key) { 'this is a randomly generated key, I promise' }
  let(:user) { FactoryGirl.build(:user, id:1, api_key:api_key) }
  let(:message) { FactoryGirl.build(:message) }
  let(:contact) { FactoryGirl.build(:user, id:2, username: :contact) }
  let(:otro_contact) { FactoryGirl.build(:user, id:3, username: :otro) }
  let(:message_params) { {sender_id: user.id, receiver_id: contact.id,
    sent_at: Time.zone.now, text: :heyo} }
  let(:alt_params) { {sender_id: contact.id, receiver_id: user.id,
      sent_at: Time.zone.now, text: :whoo?} }
  
  before :each do
    otro_contact.save
    user.add_contact otro_contact
    Message.create(alt_params)
    sleep(1.second)
    @time = Time.zone.now
    user.save
    contact.save
    user.add_contact contact
    contact.accept_contact user
    Message.create(message_params)
  end
  
  describe 'Requesting new contact updates' do
    it 'should return all updates after requested date' do
      get :show, :updates_since => @time, :user_id => user.id, :api_key => api_key
      response.status.should == 200
    end
  end
end