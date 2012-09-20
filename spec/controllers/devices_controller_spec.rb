require 'spec_helper'

describe DevicesController do
  
  let(:fake_api_key) { 'this seems wrong' }
  let(:api_key) { 'this is a randomly generated key, I promise' }
  let(:device_id) {'test id'}
  let(:user) { FactoryGirl.build(
    :user, username: 'username', password:'password',
    first_name: 'first', last_name: 'last', api_key:api_key) }
    
  before :each do
    User.should_receive(:find_by_id).and_return(user);
  end
    
  describe 'Creating a device' do
    it 'should request the user add a device' do
      user.should_receive(:add_device!).with(device_id);
      post :create, device_id:device_id, :user_id => user.id,
        :api_key => user.api_key
    end

  end

  describe 'Destroying device' do
    it 'should request the user remove a device' do
      user.should_receive(:remove_device!).with(device_id);
      delete :destroy, device_id:device_id, :user_id => user.id,
        :api_key => user.api_key
      user.device_id.should == nil
    end

  end
end