class FollowsController < ApplicationController

  before_filter :login_required, :get_star

  def create
    @follow = Follow.create(:star_id => @star.id, :fans_id => current_user.id)
    redirect_to(stream_path(@star.username))
  end

  def del
    @follow = Follow.find(:first, :conditions => { :star_id => @star.id, :fans_id => current_user.id})
    @follow.destroy
    redirect_to(stream_path(@star.username))
  end

  private

  def get_star
    @star = User.find(params[:star_id])
  end

end
