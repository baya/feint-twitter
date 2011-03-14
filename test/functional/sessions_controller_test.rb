require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  def setup
    @nancy = User.create(:username => "nancy", :full_name => "nancy feng", :bio => "HoHo", :email => "nancy@t.com", :password => "123456")
    @kame = User.create(:username => "kame", :full_name => "kame chen", :bio => "HoHo", :email => "kame@t.com", :password => "123456")
  end

  test "should get login page" do
    get :new
    assert_response :success
  end

  test "should login in" do
    post :create, { :username => "kame", :password => "123456"}
    assert_redirected_to home_path
    assert session[:user_id].to_i == @kame.id
  end

  test "should not login in when username does not exist" do
    User.destroy_all(:username => "jim")
    post :create, { :username => "jim", :password => "123456"}
    assert_template(:new)
    assert_equal flash[:notice], "username does not exist"
    assert_nil session[:user_id]
  end

  test "should not login in when password does not match username" do
    post :create, { :username => "nancy", :password => "654321"}
    assert_template(:new)
    assert_equal flash[:notice], "password error"
    assert_nil session[:user_id]
  end

  test "should redirect to home path when login" do
    store_location("/kame")
    post :create, { :username => "nancy", :password => "123456" }
    assert_equal session[:user_id], @nancy.id
    assert_redirected_to stream_path("kame")
  end

  test "should logout" do
    delete :destroy
    assert_equal session[:user_id], nil
    assert_equal assigns[:current_user], nil
    assert_redirected_to "/"
  end

  def store_location(location)
    session[:forward] = location
  end

end
