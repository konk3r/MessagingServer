require 'spec_helper'

describe User do

  before :each do
    @username = 'konker'
    @password = 'password'
    @first_name = 'conker'
    @last_name = 'shocka'
    @user = User.create :username => @username, :password => @password,
      :first_name => @first_name, :last_name => @last_name
    @second_user = FactoryGirl.create :user, username: :second, id:2
  end

  describe 'Creating a new user' do
    
    it 'should fail if the username is blank' do
      @user = User.create :password => @password
      @user.should be_new_record
    end
    
    it 'should fail if the password is blank' do
      @user = User.create :username => @username
      @user.should be_new_record
    end
    
    it 'should fail if the username already exists' do
      new_user = User.create :username => @username, :password => @password,
        :first_name => @first_name, :last_name => @last_name
        
      new_user.should be_new_record
      @user.should_not be_new_record
    end
    
    it 'should contain the username and password it was created with' do
      @user.username.should == @username
      @user.password.should == @password
      @user.should_not be_new_record
    end
    
    it 'should return the full name it was created with' do
      full_name = @first_name + " " + @last_name
      @user.name.should == full_name
      @user.should_not be_new_record
    end
    
  end

  describe 'Generating JSON' do
    it 'should create JSON with limited fields for mobile requests' do
      json = @user.to_json
      json.should include "name"
      json.should include "username"
      json.should include "created_at"
      json.should_not include "password"
      json.should_not include "first_name"
      json.should_not include "last_name"
    end
  end
  
  describe 'Contact requests' do
    before :each do
      @user.add_contact(@second_user)
    end
    
    it 'should form a contact connection between users' do
      @user.contacts.where(id: @second_user.id).first
        .should == @second_user
    end
    
    it 'should accept new contact requests' do
      @second_user.accept_contact(@user)
      @user.relationships.where(contact_id:@second_user.id)
        .first.approved.should == :true.to_s
      @second_user.relationships.where(contact_id:@user.id)
        .first.approved.should == :true.to_s
    end
    
    it 'should delete contacts' do
      @user.remove_contact(@second_user)
      @user.relationships.where(contact_id:@second_user.id)
        .should be_empty
    end
  end
end

    