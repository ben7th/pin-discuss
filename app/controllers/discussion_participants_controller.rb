class DiscussionParticipantsController < ApplicationController

  before_filter :per_load
  def per_load
    @discussion_participant = DiscussionParticipant.find(params[:id]) if params[:id]
  end

  def index
    @discussion_participants = current_user.discussion_participants
  end

  def destroy
    @discussion_participant.hide!
    refresh_local_page
  end

end