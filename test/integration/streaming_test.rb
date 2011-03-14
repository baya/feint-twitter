# -*- coding: utf-8 -*-
require 'test_helper'

class StreamingTest < ActionController::IntegrationTest

  def setup
    @nancy = Factory(:user, :username => "nancy", :bio => "bala...")
    @jack = Factory(:user, :username => "jack")
    @aaron = Factory(:user, :username => "aaron")
  end

  test "A user can log in to his account. @constraint(lands on his stream page)" do
    visit new_session_path
    within "#session" do
      fill_in "username", :with => @nancy.username
      fill_in "password", :with => "123456"
    end
    click_button "Login"
    assert_equal "/home", current_path
    assert has_content?("Logout")
    assert has_content?(@nancy.full_name)
  end

  test "A user’s stream page is accessed via a URL such as '/jakob' or '/chad'" do
    msg = Message.create(:user_id => @nancy.id, :body => "nobe go zig des")
    visit stream_path(@nancy.username)
    assert has_content?(msg.body)
  end

  test "A user can see their own stream in quasi real-time on their stream page." do
    enable_javascript
    Follow.create(:star_id => @jack.id, :fans_id => @nancy.id)
    Follow.create(:star_id => @aaron.id, :fans_id => @nancy.id)
    login_step(@nancy)
    visit "/home"
    msg1 = @jack.say("body bi body")
    assert has_no_content?(msg1.body)
    sleep(1)
    msg2 = @aaron.say("BalaBala")
    # waiting until execute javascript
    sleep(3)
    assert has_content?(msg2.body)
  end

  test "Anyone can visit the home page and view a quasi real-time stream of all messages" do
    enable_javascript
    visit "/"
    assert has_no_content?("kick me")
    sleep(1)
    msg1 = @aaron.say("kick me")
    sleep(3)
    assert has_content?(msg1.body)
  end

end
