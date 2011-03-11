class Message < ActiveRecord::Base
  belongs_to :user
  validates_length_of :body, :maximum => 140
end
