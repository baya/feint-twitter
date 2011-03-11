require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  test "has many messages" do
    assert_equal users(:jim), messages(:one).user
  end
end
