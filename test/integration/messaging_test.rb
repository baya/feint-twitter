# -*- coding: utf-8 -*-
require 'test_helper'

class MessagingTest < ActionController::IntegrationTest

  def setup
    @nancy = Factory(:user, :username => "nancy")
    @kame = Factory(:user, :username => "kame")
    @jack = Factory(:user, :username => "jack")
    @aaron = Factory(:user, :username => "aaron")
  end

  test "A user can send a message to another person’s stream by prepending @accountname to the message" do
    login_step(@nancy)
    msg_text = "@#{@kame.username} How can I get the bike?"
    send_message_step(@nancy, msg_text)
    login_step(@kame)
    visit "/home"
    # save_and_open_page
    assert has_selector?("div.msg", :text => msg_text, :visible => true )
  end

  test "A user can send a message to his stream from his stream page if message no more than 140 characters long" do
    login_step(@nancy)
    msg_text = "Good weather today"
    send_message_step(@nancy, msg_text)
    visit stream_path(@nancy.username)
    # save_and_open_page
    assert has_selector?("div.msg", :text => msg_text, :visible => true )
  end

  test "A user send a message fail which was more than 140 characters long" do
    login_step(@nancy)
    msg_text = "Good weather today" * 20
    assert msg_text.size > 140
    send_message_step(@nancy, msg_text)
    visit stream_path(@nancy.username)
    # save_and_open_page
    assert has_no_selector?("div.msg", :text => msg_text, :visible => true )
  end

  def send_message_step(user, msg_text)
    login_step(user)
    visit "/home"
    within "div#say-box" do
      fill_in "message", :with => msg_text
    end
    click_button "submit"
  end

end
