require 'spec_helper'

describe DevicesController do
  
  let(:device_id) {'test id'}
  let(:user) { FactoryGirl.build(
    :user, username: 'username', password:'password',
    first_name: 'first', last_name: 'last') }
    
  before :each do
    User.should_receive(:find_by_id).and_return(user);
  end
    
  describe 'Creating a device' do
    it 'should request the user add a device' do
      user.should_receive(:add_device).with(device_id);
      post :create, id:user.id, device_id:device_id
    end

  end

  describe 'Destroying device' do
    it 'should request the user remove a device' do
      user.should_receive(:remove_device).with(device_id);
      delete :destroy, id:user.id, device_id:device_id
    end

  end
end