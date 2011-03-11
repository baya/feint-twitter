# -*- coding: utf-8 -*-

require 'test_helper'

class FollowingTest < ActionController::IntegrationTest

  def setup
    @nancy = Factory(:user, :username => "nancy")
    @kame = Factory(:user, :username => "kame")
    @jack = Factory(:user, :username => "jack")
    @aaron = Factory(:user, :username => "aaron")
  end

  test "A user can follow any number of other user’s stream" do
    login_step(@nancy)
    follow_stream_step(@kame)
    assert @kame.fans.include?(@nancy)
    assert @nancy.stars.include?(@kame)
    follow_stream_step(@jack)
    assert @jack.fans.include?(@nancy)
    assert @nancy.stars.include?(@jack)
  end

  test "A user can see a list of people following them" do
    follow_background
    login_step(@nancy)
    visit '/home'
    @nancy.stars.each { |star|
      assert has_selector?('li', :text => star.username)
    }
    visit '/nancy'
    @nancy.stars.each { |star|
      assert has_selector?('li', :text => star.username)
    }
  end

  test "A user can see a list of people they are following" do
    follow_background
    login_step(@nancy)
    visit '/home'
    @nancy.fans.each { |fan|
      assert has_selector?('li', :text => fan.username)
    }
    visit '/nancy'
    @nancy.fans.each { |fan|
      assert has_selector?('li', :text => fan.username)
    }
  end

  test "A user can unfollow another user by visiting their stream page and clicking 'Unfollow'" do
    follow_background
    login_step(@nancy)
    assert @nancy.stars.include?(@aaron)
    unfollow_stream_step(@aaron)
    assert !@nancy.stars.include?(@aaron)
  end

  test "A user in his stream page will not see any follow or unfollow button" do
    login_step(@nancy)
    visit stream_path(@nancy.username)
    save_and_open_page
    assert has_no_button?("follow")
    assert has_no_button?("unfollow")
  end

  def follow_background
    Follow.create(:star_id => @nancy.id, :fans_id => @kame.id)
    Follow.create(:star_id => @nancy.id, :fans_id => @jack.id)
    Follow.create(:star_id => @nancy.id, :fans_id => @aaron.id)
    Follow.create(:star_id => @aaron.id, :fans_id => @nancy.id)
    Follow.create(:star_id => @aaron.id, :fans_id => @jack.id)
    Follow.create(:star_id => @kame.id, :fans_id => @nancy.id)
  end

end
