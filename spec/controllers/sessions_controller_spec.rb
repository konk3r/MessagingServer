require 'spec_helper'

describe SessionsController do
  
  let(:fake_api_key) { 'this seems wrong' }
  let(:api_key) { 'this is a randomly generated key, I promise' }
  let(:user) { FactoryGirl.build :user, :username => 'username', :password => 'password', :api_key => api_key }
  let(:incorrect_password) { 'wrong_password' }
  
  
  describe 'Creating a session' do
    describe 'Logging in' do
      
      describe 'Successful login' do
        before :each do
          User.should_receive(:find_by_username).with(user.username)
            .and_return user
        end
        
        it 'should return status 200' do
          post :create, {:username => user.username, :password => user.password}
          response.status.should == 200
        end
        
        it 'should return an api key' do
          user.should_receive(:generate_api_key!)
          post :create, {:username => user.username, :password => user.password}
          response.body.should include "api_key"
        end
        
        it 'should set api key in user' do
          user.should_receive(:generate_api_key!)
          post :create, {:username => user.username, :password => user.password}
        end
      end
      
      describe "Unsuccessful login" do
        it 'should return status 401 and an error message for an incorrect password' do
          User.should_receive(:find_by_username).with(user.username)
            .and_return user
            
          post :create, {:username => user.username, :password => incorrect_password}
          response.status.should == 401
          response.body.should include "error"
        end
        
        it 'should return status 401 and an error message for an non existent user' do
          post :create, {:username => user.username, :password => incorrect_password}
          response.status.should == 401
          response.body.should include "error"
        end
      end
    end
  end

  describe 'Logging out' do
    before :each do
      User.should_receive(:find_by_id).and_return(user)
    end
    
    it 'should give a 401 if the api key is not valid' do
      post :destroy, :user_id => user.id, :api_key => fake_api_key
      response.status.should == 401
    end
    
    it 'should delete the api key from the user' do
      user.should_receive(:remove_api_key!)
      post :destroy, :user_id => user.id, :api_key => user.api_key
    end
  end
end