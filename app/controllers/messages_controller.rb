class MessagesController < ApplicationController

  before_filter :login_required, :only => [:new, :create]

  def index
    @messages = Message.all(:order => "created_at DESC")
  end

  def realtime
    c_time = params[:c_time]
    if params[:user_id]
      user = User.find(params[:user_id])
      msg = user.stream_msgs(:conditions => ["messages.created_at > ?", c_time], :limit => 1)[0]
    else
      msg = Message.find(:first, :conditions => ["created_at > ?", c_time], :order => "created_at DESC")
    end
    render :json => msg.to_json(:methods => :username)
  end

  def home
    if current_user
      @messages = current_user.stream_msgs
    else
      redirect_to root_path
    end
  end

  def user
    @user = User.find_by_username(params[:username])
    if @user
      @messages = @user.messages
    else
      redirect_to root_path
    end
  end

  def create
    @message = current_user.say(params[:message])
    redirect_to home_path
  end

  def destroy
    @message = Message.find(params[:id])
    @message.destroy
    redirect_to(messages_url)
  end

end
