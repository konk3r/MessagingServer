require 'spec_helper'

describe MessagesController do
  describe 'Sending a message' do
    it 'should not send a message if user is not authenticated'
    it 'should not send a message if sending user does not match the authenticated user'
  end
  
  describe 'Loading conversation' do
    it 'should pull up all messages between both users sorted by time sent'
    it 'should return messages in json format'
    it 'should throw an error if one of the users does not exist'
  end
  
  describe 'Updating a message' do
    
  end
  
  describe 'Deleting a message' do
    
  end
end