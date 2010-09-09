class HTMLParse
  module ClassMethods
    def parse(html)
      array = split2array(html)
      plain = ""
      formats = []
      point = 0
      array.each do |item|
        m = item.match(/<br[^>]*>/)
        if m
          plain << "\n"
          point += 1
          next
        end
        m = item.match(/<span([^>]*)>([^<]*)<\/span>/)
        if m
          plain << m[2]

          from = point + 1
          point += m[2].chars.count
          to = point
          m_style = m[1].match(/style=("|')(.*)("|')/)
          if m_style
            kinds = m_style[2].split(";")
            kinds.map! do |kind|
              case kind
              when "font-weight:bold" then "bold"
              when "font-style:italic" then "italic"
              else kind
              end
            end
            formats << {:from=>from,:to=>to,:style=>kinds}
          end
          next
        end
        plain << item
        point += item.chars.count
      end
      return {:formats=>formats,:plain=>plain}
    end

    def split2array(html)
      html.gsub!("\n","")
      array = html.split(/(<span[^>]*>[^<]*<\/span>)|(<br[^>]*>)/)
      array.delete_if{|str|str == ""}
      array
    end
  end
  extend ClassMethods
end