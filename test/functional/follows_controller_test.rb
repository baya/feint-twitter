require 'test_helper'

class FollowsControllerTest < ActionController::TestCase

  def setup
    clear_data
    @nancy = User.create(:username => "nancy", :full_name => "nancy feng", :bio => "HoHo", :email => "nancy@t.com", :password => "123456")
    @kame = User.create(:username => "kame", :full_name => "kame chen", :bio => "HoHo", :email => "kame@t.com", :password => "123456")
    @msg1 = @nancy.messages.create(:body => "HOHO")
    @msg2 = @nancy.messages.create(:body => "MMM")
  end

  test "should create follow if user has logined" do
    login(@nancy)
    assert_difference('Follow.count') do
      post :create, { :star_id => @kame.id }
    end
    assert @nancy.stars.map(&:id).include?(@kame.id)
    assert @kame.fans.map(&:id).include?(@nancy.id)
    assert_redirected_to stream_path(@kame.username)
  end

  test "should not create follow if user not login" do
    logout
    assert_no_difference('Follow.count') do
      post :create, { :star_id => @kame.id }
    end
    assert_redirected_to new_session_path
  end

  test "should unfollow if user has logined" do
    login(@nancy)
    Follow.create!(:star_id => @kame.id, :fans_id => @nancy.id)
    assert_difference('Follow.count', -1) do
      post :del, { :star_id => @kame.id }
    end
    assert !@nancy.stars.map(&:id).include?(@kame.id)
    assert !@kame.fans.map(&:id).include?(@nancy.id)
    assert_redirected_to stream_path(@kame.username)
  end

  test "should not unfollow if user not login" do
    logout
    Follow.create!(:star_id => @kame.id, :fans_id => @nancy.id)
    assert_difference('Follow.count', 0) do
      post :del, { :star_id => @kame.id }
    end
    assert_redirected_to new_session_path
  end

end







