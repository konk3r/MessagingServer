require 'spec_helper'

describe SessionsController do
  before :all do
    @username = "username"
    @password = "password"
    @incorrect_password = "wrong"
  end
  
  describe 'Creating a session' do
    describe 'Logging in' do
      
      describe 'Successful login' do
        before :each do
          @user = FactoryGirl.build :user, :username => @username, :password => @password
          User.should_receive(:find_by_username).with(@username)
            .and_return @user
          post :create, {:username => @username, :password => @password}
        end
        
        it 'should return status 200' do
          response.status.should == 200
        end
        
        it 'should return the json representation of the user' do
          response.body.should == @user.to_json
        end
      end
      
      describe "Unsuccessful login" do
        it 'should return status 401 and an error message for an incorrect password' do
          @user = FactoryGirl.build :user, :username => @username, :password => @password
          User.should_receive(:find_by_username).with(@username)
            .and_return @user
            
          post :create, {:username => @username, :password => @incorrect_password}
          response.status.should == 401
          response.body.should include "error"
        end
        
        it 'should return status 401 and an error message for an non existent user' do
          post :create, {:username => @username, :password => @incorrect_password}
          response.status.should == 401
          response.body.should include "error"
        end
      end
    end
  end

  describe 'Logging out' do
    before :each do
      session[:user_id] = "fake_id"
      post :destroy
    end
    
    it 'should destroy an existing session if a user logs out' do
      session[:user_id].should == nil
    end
  end
end