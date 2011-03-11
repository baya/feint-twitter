module StepHelper

  def login_step(user)
    visit new_session_path
    within("#session") do
      fill_in("username", :with => user.username)
      fill_in("password", :with => "123456")
    end
    click_button("Login")
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
