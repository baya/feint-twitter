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
    @user.save ? redirect_to(@user) : render(:action => "new")
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
