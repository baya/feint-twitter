require 'test_helper'

class MessagesControllerTest < ActionController::TestCase

  def setup
    @nancy = User.create(:username => "nancy", :full_name => "nancy feng", :bio => "HoHo", :email => "nancy@t.com", :password => "123456")
    @msg1 = @nancy.messages.create(:body => "HOHO")
    @msg2 = @nancy.messages.create(:body => "MMM")
    @current_user = User.find(session[:user_id]) unless session[:user_id].blank?
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:messages)
  end

  test "should create message if user authenticated" do
    login(@nancy)
    assert_difference('Message.count') do
      post :create, { :message => "GoGo"}
    end
    assert_redirected_to home_path
  end

  test "should not create message if user not authenticated" do
    logout
    assert_no_difference('Message.count') do
      post :create, :message => { :body => "KaoKao"}
    end
    assert_redirected_to new_session_path
  end

  test "should get home stream if user authenticated" do
    login(@nancy)
    get :home
    assert_response :success
  end

  test "should not get home stream if user not authenticated" do
    logout
    get :home
    assert_redirected_to root_path
  end

  test "should get user stream if username exist" do
    get :user, { :username => "nancy"}
    assert_select "img.avatar"
    assert_select "form.follow"
    assert_response :success
  end

  test "should not get user stream if username not exist" do
    User.destroy_all(:username => "wutuobang")
    get :user, { :username => "wutuobang"}
    assert_redirected_to root_path
  end

end
