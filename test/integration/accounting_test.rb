require 'test_helper'

class AccountingTest < ActionController::IntegrationTest

  def setup
    @aaron_hash = { :username => "aaron", :full_name => "aaron_zhang", :email => "aaronzhang@gmail.com", :password => "123456", :bio => "BalaBala"}
    @nancy = Factory(:user, :username => "nancy", :bio => "bala...")
  end

  def teardown
    Capybara.reset_sessions!
  end

  test "A person can create a user account" do
    visit new_user_path
    fill_in "user[username]", :with => @aaron_hash[:username]
    fill_in "user[full_name]", :with => @aaron_hash[:full_name]
    fill_in "user[email]", :with => @aaron_hash[:email]
    fill_in "user[password]", :with => @aaron_hash[:password]
    fill_in "user[password_confirmation]", :with => @aaron_hash[:password]
    fill_in "user[bio]", :with => @aaron_hash[:bio]
    attach_file "user[image]", image_path("rails.png")
    click_button "submit"
    aaron = User.find_by_username("aaron")
    assert aaron.password == Digest::MD5.hexdigest(@aaron_hash[:password])
    assert aaron.full_name == @aaron_hash[:full_name]
    assert has_selector?("a", :content => aaron.full_name)
    assert File.exist?(File.join(Rails.root.to_s, "public", aaron.avatar_url))
  end

  test "A user can view their account information of their stream page" do
    upload_avatar_step(@nancy, "rails.png")
    reset_sessions!
    visit stream_path(@nancy.username)
    assert has_content?(@nancy.full_name)
    assert has_content?(@nancy.bio)
    # assert has_xpath?(".//img[@src=\"#{@nancy.avatar_url}\"]")
  end

  test "A user can edit their account information of their stream page" do
    login_step(@nancy)
    visit stream_path(@nancy.username)
    click_link("account setting")
    fill_in("user[bio]", :with => "HaHa")
    fill_in("user[email]", :with => "test@gmail.com")
    fill_in("user[full_name]", :with => "kame chen")
    attach_file "user[image]", image_path("me.jpg")
    click_button "Update"
    @nancy.reload
    assert_equal @nancy.bio, "HaHa"
    assert_equal @nancy.email, "test@gmail.com"
    assert_equal @nancy.full_name, "kame chen"
  end

  def upload_avatar_step(user, avatar_name)
    login_step(user)
    visit edit_user_path(user)
    attach_file "user[image]", image_path(avatar_name)
    click_button "Update"
  end

end
