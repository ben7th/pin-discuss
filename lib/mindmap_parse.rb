require 'xml/xslt'
require "rexml/document"

class MindmapParse
  def initialize(struct)
    @struct_text = Nokogiri::XML(struct).at_css("Nodes").to_s
  end

  # 把导图 转换成 bundle 格式的xml
  def parse
    xsltpath = "#{RAILS_ROOT}/public/xslt/mindpin_to_bundle.xslt"
    bundle_xml = self.class.xslt_transform(@struct_text,File.read(xsltpath))
    Nokogiri::XML(bundle_xml).at_css("bundle").to_s
  end

  def self.xslt_transform(xml_str,xslt_str)
    xslt = XML::XSLT.new()
    xslt.xml = REXML::Document.new xml_str
    xslt.xsl = REXML::Document.new xslt_str
    out=xslt.serve()
    system_os = Config::CONFIG['host_os']
    if system_os=="mswin32"
      out.to_s
    elsif system_os=="linux-gnu"
      out.to_s.gsub(/&amp;/,'&')
    else
      out.to_s
    end
  end
end
