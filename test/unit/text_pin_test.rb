require 'test_helper'

class TextPinTest < ActiveSupport::TestCase

  test "格式内容分析" do
    texts = {
      "天气相当的热\n不是一般的热\n浑身湿透"=>["天","气","相","当","的","热","\n","不","是","一","般","的","热","\n","浑","身","湿","透"],
      "天气 相   当的热\n不\t是一般的热"=>['天','气',' ','相',' ',' ',' ','当','的','热',"\n",'不',"\t",'是','一','般','的','热'],
      "today,天气相当的热\n不是一般的热,sohot"=>["t","o","d","a","y",",","天","气","相","当","的","热","\n","不","是","一","般","的","热",",","s","o","h","o","t"]

    }
    texts.each do |text,value|
      struct = %~
      <text>
        <content><![CDATA[#{text}]]></content>
        <format><bold from='1' to='11' /><italic from='12' to='17' /></format>
      </text>
      ~
      text_pin = TextPin.new(:struct=>struct)
      assert_equal text_pin.content_array,value
      text_pin.formats.each do |format|
        case format
        when format.kinds,["bold"]
          assert_equal format.from,1
          assert_equal format.to,11
        when format.kinds,["italic"]
          assert_equal format.from,12
          assert_equal format.to,17
        end
      end
    end
  end

  test "格式内容转换" do
    texts = {
      "天气相当的热\n不是一般的热\n浑身湿透"=>%`<span style='font-weight:bold;'>天气相当</span>的热<br/><span style='font-style:italic;'>不是一般</span>的热<br/>浑身湿透`,
    }
    texts.each do |text,value|
      struct = %~
        <text>
          <content><![CDATA[#{text}]]></content>
          <format><bold from='1' to='4' /><italic from='8' to='11' /></format>
        </text>
      #~
      text_pin = TextPin.new(:struct=>struct)
      assert_equal text_pin.to_html,value
    end
  end

end
