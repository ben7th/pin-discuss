require 'test_helper'

class HtmlParseTest < ActiveSupport::TestCase

  test "第一个测试" do
    html.each_with_index do |item,i|
      result = HTMLParse.parse(item)
      assert_equal result[:formats],formats[i]
      assert_equal result[:plain],plain[i]
    end
  end

  def html
    [
      "ab<span style='font-weight:bold;'>cd</span><br/>e<span style='font-weight:bold;'>fg</span>h",
      "ab<span style='font-weight:bold;'> c&lt;我&gt;</span> <br/>\ne<span style='font-weight:bold;'>fg</span>h",
      "abc\ndef\n",
      "a<span style='font-weight:bold;'>b</span><br/>c<span style='font-weight:bold;'>d</span>e",
      "<span style='font-weight:bold;'>ab\\nc</span>",
      "<span style='font-weight:bold;font-style:italic;'>ab\\nc</span>",
      "<span>123</span>"
    ]
  end

  def plain
    [
      "abcd\nefgh",
      "ab c&lt;我&gt; \nefgh",
      "abcdef",
      "ab\ncde",
      "ab\\nc",
      "ab\\nc",
      "123"
    ]
  end

  def formats
    [
      [{:from=>3,:to=>4,:style=>["bold"]},
        {:from=>7,:to=>8,:style=>["bold"]}],
      
      [{:from=>3,:to=>13,:style=>["bold"]},
        {:from=>17,:to=>18,:style=>["bold"]}],
      [],
      [{:from=>2,:to=>2,:style=>["bold"]},
        {:from=>5,:to=>5,:style=>["bold"]}],
      [{:style=>["bold"], :from=>1, :to=>5}],
      [{:style=>["bold","italic"], :from=>1, :to=>5}],
      []
    ]
  end
end