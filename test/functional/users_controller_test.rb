require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    @nancy = User.create(:username => "nancy", :full_name => "nancy feng", :bio => "HoHo", :email => "nancy@t.com", :password => "123456")
    @jack = User.create(:username => "jack", :full_name => "jack huang", :bio => "Fat", :email => "jack@t.com", :password => "123456")
    @kame = User.create(:username => "kame", :full_name => "kame chen", :bio => "Fat", :email => "kame@t.com", :password => "123456")
    @man_hash = { :username => "bobo", :full_name => "bobo kaka", :bio => "cute", :email => "bobo@t.com", :password => "123456"}
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, :user => { :username => "tony", :full_name => "Tony Guy", :bio => "good man", :email => "tony@t.com", :password => "123456", :password_confirmation => "123456"}
    end
    assert_equal session[:user_id], assigns(:user).id
    assert_equal assigns(:current_user), assigns(:user)
    assert_redirected_to user_path(assigns(:user))
  end

  test "should not create user when username repeat" do
    assert_no_difference('User.count') do
      post :create, :user => { :username => "nancy", :full_name => "jim bang", :bio => "good man", :email => "jim@t.com", :password => "123456"}
    end
    assert_equal assigns(:user).errors[:username], "has already been taken"
    assert_template("new")
  end

  test "should not create user when email repeat" do
    assert_no_difference('User.count') do
      post :create, :user => { :username => "joe", :full_name => "joe clark", :bio => "good man", :email => "jack@t.com", :password => "123456"}
    end
    assert_equal assigns(:user).errors[:email], "has already been taken"
    assert_template("new")
  end

  test "should not create user if password blank" do
    text_password = " "
    post :create, :user => @man_hash.merge(:password => text_password)
    assert_equal assigns(:user).errors[:password], "can't be blank"
    assert_template("new")
  end

  test "should not create user if password not match" do
    text_password = "secret123"
    text_confirm = "secret124"
    post :create, :user => @man_hash.merge(:password => text_password, :password_confirmation => text_confirm)
    assert_equal assigns(:user).errors[:password], "doesn't match confirmation"
    assert_template("new")
  end

  test "should create user with encrypted password" do
    text_password = "secret123"
    post :create, :user => @man_hash.merge(:password => text_password)
    user = assigns(:user)
    assert_redirected_to user_path(user)
    assert_equal user.password, Digest::MD5.hexdigest(text_password)
  end

  test "should show user" do
    get :show, :id => @nancy.to_param
    assert_response :success
  end

  test "should get edit if autenticated" do
    login(@jack)
    get :edit, :id => @jack.to_param
    assert_response :success
  end

  test "should not get edit if not autenticated" do
    login(@nancy)
    get :edit, :id => @jack.to_param
    assert_redirected_to stream_path(@jack.username)
  end

  test "should update user if autenticated" do
    login(@kame)
    put :update, :id => @kame.to_param, :user => { :bio => "Tall"}
    assert_redirected_to user_path(assigns(:user))
  end

  test "should not update user if not autenticated" do
    logout
    put :update, :id => @kame.to_param, :user => { :bio => "Tall"}
    assert_redirected_to stream_path(@kame.username)
  end

end
