class User < UserBase
  include DiscussionParticipant::UserMethods
  include Workspace::UserMethods
end