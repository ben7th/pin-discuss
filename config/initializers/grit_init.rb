require "grit"
module Grit
  class Git
    alias origin_sh sh
    alias origin_wild_sh wild_sh

    def sh(command)
      p "--sh-- #{command}"
      origin_sh(command)
    end

    def wild_sh(command)
      p "--wild_sh-- #{command}"
      origin_wild_sh(command)
    end
  end
end
