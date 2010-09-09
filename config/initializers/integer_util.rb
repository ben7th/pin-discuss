class Integer
  def to_cn_str
    arr = Integer.split_by_4_digital(self)
    str = Integer.join_wan_and_yi arr.map{|x| Integer.transform_4digitals_to_cn(x)}
    result = str.sub(/^一十/,'十')
    return Integer.remove_ling_on_tail(result)
  end

  # 把数字转成字符串，并且拆分成四个字符一组的数组
  def self.split_by_4_digital(num)
    arr = num.to_s.split("")
    result = []
    while !arr.blank? do result << arr.pop(4) end
    result.reverse
  end

  # 四位数字字符串转换成汉字字符串
  def self.transform_4digitals_to_cn(array)
    result = []
    array.reverse.each_with_index do |digital_str,digital_index|
      result << trans_digital_to_cn(digital_str,digital_index)
    end
    result = (result.reverse*'').sub(/零+/,'零')
    return remove_ling_on_tail(result)
  end

  def self.remove_ling_on_tail(source)
    return source=='零' ? source : source.sub(/零+$/,'')
  end

  def self.trans_digital_to_cn(digital_str,digital_index)
    char_1 = ['零','一','二','三','四','五','六','七','八','九'][digital_str.to_i]
    char_2 = char_1 == '零' ? '' : ['','十','百','千'][digital_index]
    return "#{char_1}#{char_2}"
  end

  def self.join_wan_and_yi(str_arr)
    str_wan = str_arr[-2]
    str_yi = str_arr[-3]
    # 如果是空值，或者 “零” 都不添单位
    str_arr[-2] = "#{str_wan}万" if (!str_wan.blank? && str_wan!='零')
    str_arr[-3] = "#{str_yi}亿" if (!str_yi.blank? && str_yi!='零')
    str_arr*''
  end
end
