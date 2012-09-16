require 'spec_helper'

describe UsersController do
  let(:username) { 'username' }
  let(:incorrect_username) { 'incorrect_username' }
  let(:password) { 'password' }
  let(:user) { FactoryGirl.build(
    :user, username:username, password:incorrect_username) }
  
  describe 'Creating a user' do
    it 'should result in a create call being sent to the User model' do
      User.should_receive(:create)
        .with(:username => username, :password => password)
        .and_return(user)
        
      post :create, {:username => username, :password => password}
    end
    
    describe 'Status codes' do
      describe 'Unique/duplicate requests' do
        
        before :each do
          post :create, {:username => username, :password => password}
        end
      
        it "should return 201: created for a new user" do
          response.status.should == 201
        end
      
        it "should return 409: Conflict for a duplicate user" do
          post :create, {:username => username, :password => password}
          response.status.should == 409
        end
      end

      it "should return 400: Bad request if password is not sent" do
        post :create, {:username => username}
        response.status.should == 400
      end
      
      it "should return 400: Bad request if username is not sent" do
        post :create, {:password => password}
        response.status.should == 400
      end
    end  
  end
  
  describe "Deleting a user" do
    it "should return 401 error on if not authenticated" do
      delete :destroy, {:username => incorrect_username}
      response.status.should ==  401
      response.body.should include "error"
    end
    
    it "should return 403 error user if not authenticated as that user" do
      User.should_receive(:find_by_id).and_return(user)
      
      delete :destroy, {:username => incorrect_username}
      response.status.should ==  403
      response.body.should include "error"
    end
    
    it "should return 200 and remove user from database" do
      User.should_receive(:find_by_id).and_return(user)
      user.should_receive(:destroy)
      
      delete :destroy, {username:username}
    end
  end
  
end