require 'spec_helper'

describe UsersController do
  let(:fake_api_key) { 'this seems wrong' }
  let(:api_key) { 'this is a randomly generated key, I promise' }
  let(:incorrect_user_id) { -1 }
  let(:user) { FactoryGirl.build(
    :user, username:'username', password:'password', first_name:'first', last_name:'last', 
    api_key:api_key) }
  
  describe 'Creating a user' do
    it 'should result in a create call being sent to the User model' do
      User.should_receive(:create)
        .with("username" => user.username, "password" => user.password)
        .and_return(user)
        
      post :create, {:username => user.username, :password => user.password}
    end
    
    it 'should contain the first and last name it was created with' do
      User.should_receive(:create)
        .with("username" => user.username, "password" => user.password,
          "first_name"=>user.first_name, "last_name"=>user.last_name)
        .and_return(user)
        
      post :create, {username:user.username, password:user.password,
        first_name:user.first_name, last_name:user.last_name}
    end
    
    describe 'Status codes' do
      describe 'Unique/duplicate requests' do
        
        before :each do
          post :create, {:username => user.username, :password => user.password}
        end
      
        it "should return 201: created for a new user" do
          response.status.should == 201
        end
      
        it "should return 409: Conflict for a duplicate user" do
          post :create, {:username => user.username, :password => user.password}
          response.status.should == 409
        end
      end

      it "should return 400: Bad request if password is not sent" do
        post :create, {:username => user.username}
        response.status.should == 400
      end
      
      it "should return 400: Bad request if username is not sent" do
        post :create, {:password => user.password}
        response.status.should == 400
      end
    end  
  end
  
  describe "Deleting a user" do
    it "should return 401 error on if not authenticated" do
      delete :destroy, {id:user.id}
      response.status.should ==  401
      response.body.should include "error"
    end
    
    it "should return 403 error user if not authenticated as that user" do
      User.should_receive(:find_by_id).and_return(user)
      
      delete :destroy, {id:incorrect_user_id, :user_id => user.id,
        :api_key => user.api_key}
      response.status.should ==  403
      response.body.should include "error"
    end
    
    it "should return 200 and remove user from database" do
      User.should_receive(:find_by_id).and_return(user)
      user.should_receive(:destroy)
      
      delete :destroy, {id:user.id, :user_id => user.id,
        :api_key => user.api_key}
      
      response.status.should == 200
    end
  end
  
end