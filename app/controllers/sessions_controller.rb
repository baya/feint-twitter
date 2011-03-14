class SessionsController < ApplicationController

  def new

  end

  def create
    @user = User.find_by_username(params[:username])
    if @user
      if authenticated?(@user, params[:password])
        forward_or_redirect_to(home_path)
        session[:user_id] = @user.id
      else
        render_action_with_notice("new", "password error")
      end
    else
      render_action_with_notice("new", "username does not exist")
    end
  end

  def destroy
    self.current_user = nil
    redirect_to "/"
  end

  private

  def render_action_with_notice(action, notice)
    flash[:notice] = notice
    render :action => action
  end

end
