class DiscussionParticipant < ActiveRecord::Base
  belongs_to :participant,:class_name=>"User"
  belongs_to :document_tree

  validates_presence_of :document_tree_id

  def hide!
    self.update_attributes(:hide=>true)
  end

  module UserMethods
    def self.included(base)
      base.has_many :discussions,:foreign_key=>"participant_id",:conditions=>["hide is null or hide = 0"]
    end
  end

end
