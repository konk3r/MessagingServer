require 'spec_helper'

describe UsersController do
  describe 'Creating a user' do
    it 'should request a new user be created in the database from the given username and password' do
      User.should_receive(:create)
        .with(:username => 'konker', :password => 'password')
        .and_return(FactoryGirl.build(:user))
        
      post :create, {:username => 'konker', :password => 'password'}
    end
    
    it "should return a new user" do
      post :create, {:username => 'konker', :password => 'password'}
    end
    
  end
end