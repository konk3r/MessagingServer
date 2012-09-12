class Message < ActiveRecord::Base
  belongs_to :user_from
  belongs_to :user_to
  attr_accessible :text, :time_received, :times_sent
end
