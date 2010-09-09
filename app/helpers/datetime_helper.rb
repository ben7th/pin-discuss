module DatetimeHelper
  # 获取当前时区的时间日期的友好形式
  def qdatetime(time)
    return "<span class='date'>未知</span>" if time.nil?
    time=time.localtime
    "<span class='date'>#{time.month}月#{time.day}日 #{time.hour}:#{time.min<10 ? "0#{time.min}" : time.min}</span>"
  end
  
  # 获取当前时区的日期的友好形式(年月日时分秒)
  def qdatetimefull(time)
    return "<span class='date'>未知</span>" if time.nil?
    "<span class='date'>#{time.year}年#{_2(time.month)}月#{_2(time.day)}日 #{_2(time.hour)}:#{_2(time.min)}:#{_2(time.sec)}</span>"
  end

  # 获取当前时区的日期的友好形式(年-月-日时:分:秒)
  def qdatetimefull_with_line(time)
    return "<span class='date'>未知</span>" if time.nil?
    "<span class='date'>#{time.year}-#{_2(time.month)}-#{_2(time.day)} #{_2(time.hour)}:#{_2(time.min)}:#{_2(time.sec)}</span>"
  end

  def _2(num)
    num>9 ? num : "0#{num}"
  end
  
  # 获取当前时区的日期的数字形式(20080808)
  def qdatetimenum(time)
    return "<span class='date'>未知</span>" if time.nil?
    time=time.localtime
    "#{time.year}#{time.month<10 ? "0#{time.month}" : time.month}#{time.day<10 ? "0#{time.day}" : time.day}"
  end
  
  # 获取当前时区的日期的友好形式
  def qdate(time)
    return "<span class='date'>未知</span>" if time.nil?
    time=time.localtime
    timestr="#{time.year}年#{time.month}月#{time.day}日"
    "<span class='date'>#{timestr}</span>"
  end
  
  def qtime(time)
    return "<span class='date'>未知</span>" if time.nil?
    time=time.localtime
    "<span class='date'>#{time.hour}:#{time.min<10 ? "0#{time.min}" : time.min}</span>"
  end
  
  # 记录创建至今
  def created_from(record)
    str=record.created_at.nil? ? '未知' : get_period_str(Time.now-record.created_at)
    "<span class='date'>#{str}</span>"
  end
  
  # 记录更新至今
  def updated_from(record)
    str=record.updated_at.nil? ? '未知' : get_period_str(Time.now-record.updated_at)
    "<span class='date'>#{str}</span>"
  end
  
  # 记录创建至今
  def created_from_str(record)
    str=record.created_at.nil? ? '未知' : get_period_str(Time.now-record.created_at)
    "<span class='date'>#{str}</span><span class='quiet'>创建</span>"
  end
  
  # 记录更新至今
  def updated_from_str(record)
    str=record.updated_at.nil? ? '未知' : get_period_str(Time.now-record.updated_at)
    "<span class='date'>#{str}</span><span class='quiet'>更新</span>"
  end
  
  def show_time_by_order_type(order,record)
    if order==1
      updated_from_str record
    else
      created_from_str record
    end
  end
  
  def created_at(object)
    str=object.created_at.nil? ? '未知' : object.created_at.to_date
    "<span class='date'>#{str}</span>"
  end
  
  # 获取一个时间段的描述字符串
  def get_period_str(period)
    case period
    when 0..1.minutes then '片刻前'
    when 1.minutes..2.hours then "#{Integer period/1.minutes}分钟前"
    when 2.hours..2.days then "#{Integer period/1.hours}小时前"
    when 2.days..1.months then "#{Integer period/1.days}天前"
    when 1.months..1.years then "#{Integer period/1.months}月前"
    when 1.years..100.years then "#{Integer period/1.years - 1}年多前"
    end
  end
  
  # 获取时间段
  def get_period(hour)
    hour=hour + 8
    case hour
    when 7..12 then "上午"
    when 13..18 then "下午"
    when 3..7 then "凌晨"
    when 23..1 then "子夜"
    end
  end

  def format_in_activity(datetime)
    datetime.strftime("%Y-%m-%d %H:%M")
  end

  def year_month_and_day(datetime)
    datetime.strftime("%Y-%m-%d")
  end

  # 根据当前时间与time的间隔距离，返回时间的显示格式
  # 一年之前显示 ：--年
  # 本年之内显示 ：--月--日
  # 本天之内显示 ：--点--分
  def time_str_by_distance_of_now(time)
    if time.today?
      str = time.strftime("%H:%M")
    elsif time.year < Time.now.year
      str = "#{time.year}年"
    else
      str = "#{time.month}月#{time.day}日"
    end
    return "<span class='date'>#{str}</span>"
  end

  # 以今天 今年 为时间分割线
  # 今天的时间显示为：“今天 02:04”
  # 其他的时间显示为：“5月20日 13:51”
  # 非今年时间显示为：“2009年5月20日 13:51”
  def time_str_by_today(time)
    if time.today?
      str = "今天 #{time.strftime("%H:%M")}"
    elsif time.year < Time.now.year
      str = "#{time.year}年#{time.month}月#{time.day}日 #{time.strftime("%H:%M")}"
    else
      str = "#{time.month}月#{time.day}日 #{time.strftime("%H:%M")}"
    end
    return "<span class='date'>#{str}</span>"
  end

end