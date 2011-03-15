# -*- coding: utf-8 -*-
require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @man_hash = { :username => "eeros", :email => "jim@test.com", :bio => "bad man", :password => "123456"}
    @nancy = Factory(:user, :username => "nancy", :email => "nancy@mail.com")
    @kame = Factory(:user, :username => "kame")
    @jack = Factory(:user, :username => "jack")
    @aaron = Factory(:user, :username => "aaron")
    @zh_man = Factory(:user, :username => "张三风")
    @gravatar_api = "http://www.gravatar.com/avatar"
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
    b_time = Time.now - 8.hours
    sleep(1)
    msg2 = @aaron.say("GoGola")
    assert @jack.stream_msgs.include?(msg1)
    assert @aaron.stream_msgs.include?(msg2)
    assert @nancy.stream_msgs.include?(msg1)
    assert @nancy.stream_msgs.include?(msg2)
    assert @nancy.stream_msgs(:conditions => ["messages.created_at <= ? ", b_time]).include?(msg1)
    assert !@nancy.stream_msgs(:conditions => ["messages.created_at < ? ", b_time]).include?(msg2)
    assert @nancy.stream_msgs(:conditions => ["messages.created_at > ? ", b_time]).include?(msg2)
    msg3 = @aaron.say("JJJ")
    msgs = @nancy.stream_msgs(:conditions => ["messages.created_at > ? ", b_time], :limit => 1)
    assert_equal msgs.size, 1
    msgs = @nancy.stream_msgs(:conditions => ["messages.created_at > ? ", b_time], :limit => 2, :include => :user)
    assert_equal msgs.size, 2
    assert_equal msgs.map(&:username), [@aaron.username, @aaron.username]
  end

  test "avatar configures" do
    User.class_eval {
      avatar_config :storage_path => File.join(*[Rails.root.to_s, "public", "pavatar"]),
      :max_size => 2.megabyte
    }
    assert_equal @nancy.avatar_options[:storage_path], File.join(*[Rails.root.to_s, "public", "pavatar"])
    assert_equal @nancy.avatar_options[:max_size], 2.megabyte
    assert_equal @nancy.avatar_options[:avatar_api], @gravatar_api
  end

  test "id to name path" do
    diskfile_path = File.join(@nancy.avatar_options[:storage_path], @nancy.id_to_namepath)
    save_dir = File.dirname(diskfile_path)
    unless File.directory?(save_dir)
      FileUtils.mkdir_p(save_dir)
    end
    FileUtils.touch(diskfile_path) unless File.exist?(diskfile_path)
    assert_equal @nancy.id_to_namepath, id_to_namepath(@nancy)
    assert_equal @nancy.avatar_url, @nancy.avatar_options[:storage_path].sub(File.join(Rails.root.to_s, "public"), '') + @nancy.id_to_namepath
    puts @nancy.id_to_namepath
  end

  test "user use gravatar url if user not upload image" do
    FileUtils.rm_r(@nancy.avatar_options[:storage_path]) if File.directory?(@nancy.avatar_options[:storage_path])
    options = { :size => 200, :default => "wavatar"}
    email = @nancy.email.strip.downcase
    assert_equal @nancy.avatar_url(options), @gravatar_api + "/" + Digest::MD5.hexdigest(@nancy.email) + "?" + options.to_param
  end

  def id_to_namepath(user)
    num_str = user.id.to_s.size % 2 == 0 ? user.id.to_s : "0" + user.id.to_s
    "/" + num_str.scan(/\d{2}/).join("/")
  end

  def follow_background
    Follow.create(:star_id => @nancy.id, :fans_id => @jack.id)
    Follow.create(:star_id => @nancy.id, :fans_id => @kame.id)
    Follow.create(:star_id => @kame.id, :fans_id => @nancy.id)
    Follow.create(:star_id => @aaron.id, :fans_id => @nancy.id)
    Follow.create(:star_id => @jack.id, :fans_id => @nancy.id)
  end

end
