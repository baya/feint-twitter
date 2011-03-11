require 'test_helper'

class AccountingTest < ActionController::IntegrationTest

  def setup
    @aaron_hash = { :username => "aaron", :full_name => "aaron_zhang", :email => "aaronzhang@gmail.com", :password => "123456", :bio => "BalaBala"}
    @nancy = Factory(:user, :username => "nancy", :bio => "bala...")
  end

  test "A person can create a user account" do
    visit new_user_path
    fill_in "user[username]", :with => @aaron_hash[:username]
    fill_in "user[full_name]", :with => @aaron_hash[:full_name]
    fill_in "user[email]", :with => @aaron_hash[:email]
    fill_in "user[password]", :with => @aaron_hash[:password]
    fill_in "user[password_confirmation]", :with => @aaron_hash[:password]
    fill_in "user[bio]", :with => @aaron_hash[:bio]
    click_button "submit"
    aaron = User.find_by_username("aaron")
    assert aaron.password == Digest::MD5.hexdigest(@aaron_hash[:password])
    assert aaron.full_name == @aaron_hash[:full_name]
  end

  test "A user can view their account information of their stream page" do
    visit stream_path(@nancy.username)
    # save_and_open_page
    within "div.bio" do
      assert has_content?(@nancy.full_name)
      assert has_content?(@nancy.bio)
      assert has_content?(@nancy.username)
    end
  end

  test "A user can edit their account information of their stream page" do
    login_step(@nancy)
    visit stream_path(@nancy.username)
    click_link("account setting")
    fill_in("user[bio]", :with => "HaHa")
    fill_in("user[email]", :with => "test@gmail.com")
    fill_in("user[full_name]", :with => "kame chen")
    click_button "Update"
    @nancy.reload
    assert_equal @nancy.bio, "HaHa"
    assert_equal @nancy.email, "test@gmail.com"
    assert_equal @nancy.full_name, "kame chen"
  end

end
