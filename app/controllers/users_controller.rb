class UsersController < ApplicationController

  before_filter :get_user, :only => [:show, :edit, :update]
  before_filter :authenticate, :only => [:edit, :update]

  def show

  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      self.current_user = @user
      redirect_to(@user)
    else
      render(:action => "new")
    end
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to(@user)
    else
      render :action => "edit"
    end
  end

  private

  def authenticate
    redirect_to stream_path(@user.username) if session[:user_id] != @user.id
  end

  def get_user
    @user = User.find(params[:id])
  end

end
