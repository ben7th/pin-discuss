module WillPaginate
  module ViewHelpers
    @@pagination_options[:previous_label]='&laquo; 上一页'
    @@pagination_options[:next_label]='下一页 &raquo;'
    @@pagination_options[:inner_window]=1
    @@pagination_options[:outer_window]=1
  end
end

class AjaxLinkRenderer < WillPaginate::LinkRenderer
  def page_link_or_span(page, span_class = 'current', text = nil)
    text ||= page.to_s
    if page and page != current_page
      @template.page_link @options[:position],text,:url=>url_for(page).gsub('&amp;','&').remove_url_param('PLpos').remove_url_param('authenticity_token'),:method=>:get
    else
      @template.content_tag :span, text, :class => span_class
    end
  end
end