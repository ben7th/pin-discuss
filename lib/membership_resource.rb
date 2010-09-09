class MembershipResource < ActiveResource::Base
  self.site = CoreService.project("pin-workspace").url
  self.element_name = "membership"
end