class DiscussionParticipant < ActiveRecord::Base

  belongs_to :discussion

  validates_presence_of :discussion_id

  def hide!
    self.update_attributes(:hide=>true)
  end

  def self.discussion_participants(email)
    DiscussionParticipant.find(:all,:conditions=>["email => #{email} and hide is null or hide = 0 "])
  end

  module UserMethods
    def discussion_participants
      DiscussionParticipant.find(:all,:conditions=>["email => #{self.email} and hide is null or hide = 0 "])
    end
  end

end
