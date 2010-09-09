class User < UserBase
  include Discussion::UserMethods
  include Workspace::UserMethods
end