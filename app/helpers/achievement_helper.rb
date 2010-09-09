module AchievementHelper
  
  def show_honor(honor)
    honor = honor.downcase
    honor_str = %`
      <div class="honor-background">
        <div class="honor-pic" style="background:url(/images/achievement/#{honor}.png) no-repeat 0px 0px;"></div>
      </div>
    `
    return honor_str
  end
  
  def show_honor_detail(honor)
    return %~
      <div class="honor-div boxfix">
        <div class='fleft icon'>
          #{show_honor(honor)}
        </div>
        <div class='fleft d'>
          <h3>#{Achievement.honor_str(honor)}</h3>
          <div>#{Achievement.honor_description(honor)}</div>
        </div>
      </div>
    ~
  end

  def show_honor_32(honor)
    honor = honor.downcase
    honor_str = %`
      <div class="honor-background-32">
        <div class="honor-pic" style="background:url(/images/achievement/#{honor}_32.png) no-repeat 0px 0px;">
          <div class="award"></div>
        </div>
      </div>
    `
    return honor_str
  end

  def show_honor_32_detail(honor)
    return %~
      <div class="honor-div-32 boxfix">
        <div class='fleft'>
          #{show_honor_32(honor)}
        </div>
        <div class='fleft d'>
          <span>#{Achievement.honor_str(honor)}</span>
        </div>
      </div>
    ~
  end

end
