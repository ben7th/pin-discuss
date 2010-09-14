class DiscussionMessage < ActiveRecord::Base
  belongs_to :discussion

  validates_presence_of :mmid
  validates_presence_of :text_pin_id
end
