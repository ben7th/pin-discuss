module LightviewHelper

  def lightview_a(options,&block)
    href = options[:href]
    rel = options[:parent] ? "#{options[:parent].class}_#{options[:parent].id}" : randstr
    str = %`
    <a id="#{id}" class="lightview" href="#{href}" rel="set[#{rel}]">
    <%=yield%>
    </a>
    `
    inside_inline_layout(str,&block)
  end
end