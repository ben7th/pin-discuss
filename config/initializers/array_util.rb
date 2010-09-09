class Array

  def str_compact
    self.select do |str|
      unless str.blank? then str end
    end
  end

  def to_brackets_str
    arr_str = self.map{|str| str.to_json}*","
    "(#{arr_str})"
  end
end