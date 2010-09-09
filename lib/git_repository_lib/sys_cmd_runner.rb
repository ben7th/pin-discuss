# To change this template, choose Tools | Templates
# and open the template in the editor.

class SysCmdRunner
  attr_accessor :cmd
  attr_accessor :output
  attr_accessor :status

  attr_accessor :done

  def initialize(cmd='nil')
    @cmd = cmd
    @done = false
  end

  def done?
    @done
  end

  def run
    @output ||= _output
    @status ||= :success
  end

  def output
    run if !done?
    @output
  end

  def _output
    @output = %x[#{cmd}]
    @done = true
    if $? != 0
      @output = nil
      raise SysCmdNotFoundError,'command not found'
    end
    @output
  end
  
  class SysCmdNotFoundError < Exception
    
  end

end
