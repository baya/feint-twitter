module StepHelper

  def login_step(user)
    visit new_session_path
    # save_and_open_page
    within("#session") do
      fill_in("username", :with => user.username)
      fill_in("password", :with => "123456")
    end
    click_button("Login")
  end

  def upload_avatar_step(user, avatar_name)
    login_step(user)
    visit edit_user_path(user)
    attach_file "user[image]", image_path(avatar_name)
    click_button "Update"
  end

  def follow_stream_step(user)
    visit stream_path(user.username)
    click_button("follow")
  end

  def unfollow_stream_step(user)
    visit stream_path(user.username)
    click_button("unfollow")
  end

end
