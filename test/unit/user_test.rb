# -*- coding: utf-8 -*-
require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @man_hash = { :username => "eeros", :email => "jim@test.com", :bio => "bad man", :password => "123456"}
    @nancy = Factory(:user, :username => "nancy")
    @kame = Factory(:user, :username => "kame")
    @jack = Factory(:user, :username => "jack")
    @aaron = Factory(:user, :username => "aaron")
    @zh_man = Factory(:user, :username => "张三风")
  end

  test "has many messages" do
    user = users(:jim)
    assert_equal 2, user.messages.count
  end

  test "username must be unique" do
    user1 = User.create(@man_hash)
    assert !user1.new_record?
    user2 = User.create(@man_hash.merge(:email => "jim@real.com"))
    assert user2.new_record?
    assert_equal user2.errors["username"], "has already been taken"
  end

  test "email must be unique" do
    user1 = User.create(@man_hash)
    assert !user1.new_record?
    user2 = User.create(@man_hash.merge(:username => "kame"))
    assert user2.new_record?
    assert_equal user2.errors["email"], "has already been taken"
  end

  test "password should be encrypted" do
    lily = User.create(:username => "lily", :email => "lily@test.com", :bio => "cute girl", :password => "secret123")
    assert !lily.new_record?
    assert_equal lily.password, Digest::MD5.hexdigest("secret123")
  end

  test "get all stars and fans" do
    follow_background
    assert @nancy.fans.include?(@kame)
    assert @nancy.fans.include?(@jack)
    assert @nancy.stars.include?(@kame)
    assert @nancy.stars.include?(@aaron)
    assert @nancy.stars.include?(@jack)
  end

  test "should be a fans of star" do
    Follow.create(:star_id => @nancy.id, :fans_id => @jack.id)
    assert @jack.is_a_fans?(@nancy)
  end

  test "user say" do
    follow_background
    msg_text = "balbal..."
    msg = @jack.say(msg_text)
    assert @jack.messages.include?(msg)
    assert @jack.stream_msgs.include?(msg)
    assert @nancy.stream_msgs.include?(msg)
  end

  test "user say @somebody haha..." do
    msg_text = "@#{@kame.username} hahalala..."
    msg = @nancy.say(msg_text)
    assert @kame.stream_msgs.include?(msg)
    msg_text = "@#{@zh_man.username} 你哈"
    msg = @nancy.say(msg_text)
    assert @zh_man.stream_msgs.include?(msg)
  end

  test "stream messages" do
    Follow.create(:star_id => @aaron.id, :fans_id => @nancy.id)
    Follow.create(:star_id => @jack.id, :fans_id => @nancy.id)
    msg1 = @jack.say("BalaBala")
    msg2 = @aaron.say("GoGola")
    assert @jack.stream_msgs.include?(msg1)
    assert @aaron.stream_msgs.include?(msg2)
    assert @nancy.stream_msgs.include?(msg1)
    assert @nancy.stream_msgs.include?(msg2)
  end

  def follow_background
    Follow.create(:star_id => @nancy.id, :fans_id => @jack.id)
    Follow.create(:star_id => @nancy.id, :fans_id => @kame.id)
    Follow.create(:star_id => @kame.id, :fans_id => @nancy.id)
    Follow.create(:star_id => @aaron.id, :fans_id => @nancy.id)
    Follow.create(:star_id => @jack.id, :fans_id => @nancy.id)
  end

end
