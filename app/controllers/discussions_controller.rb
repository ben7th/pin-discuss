class DiscussionsController < ApplicationController

  before_filter :per_load
  def per_load
    @discussion = Discussion.find(params[:id]) if params[:id]
  end

  def index
    @discussions = current_user.discussions
  end

  def destroy
    @discussion.hide!
    refresh_local_page
  end

end