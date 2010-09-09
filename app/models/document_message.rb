class DocumentMessage < ActiveRecord::Base
  belongs_to :document_tree

  validates_presence_of :mmid
  validates_presence_of :text_pin_id
end
