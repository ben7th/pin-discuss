def run_cmd(cmd)
  scr = SysCmdRunner.new(cmd)
  scr.output
end