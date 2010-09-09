module PrototipHelper
  # 在页面上生成tooltip提示框
  def show_tooltip(options={},&block)
    current_user.create_self_preference if current_user.preference.blank?
    return unless current_user.preference.show_tooltip?

    # 显示过一次的气泡就用 cookies 记录下来，下次就不在显示
    # 根据flag来判断，如果没有传入flag，则忽略这一判断
    flag = options[:flag]
    unless flag.blank?
      cookies[:tooltip] ||= ''
      cookies_tooltips = cookies[:tooltip].split(',')
      return if cookies_tooltips.include?(flag)
      cookies_tooltips.push(flag)
      cookies[:tooltip] = cookies_tooltips*","
    end
    
    role = options[:when][:role]
    condition = options[:when][:condition]
    # 只有条件和当前用户角色都符合要求时，才显示tooltip
    return false unless(condition && current_user.roles.include?(role))

    # dom选择器
    dom_selector = options[:to]
    title = options[:title]
    
    target = options[:target] || 'rightMiddle'
    tip = options[:tip] || 'topLeft'

    layout_str = %`
      <script type='text/javascript'>
        $$(#{dom_selector.to_json}).each(function(el){
          new Tip(el, <%=yield.to_json%>,{
            title : #{title.to_json},
            hook: { target: #{target.to_json}, tip: #{tip.to_json} },
            hideOn: { element: 'closeButton', event: 'click' },
            stem: #{tip.to_json},
            showOn: 'none'
          });
          el.prototip.show();
        });
      </script>
    `
    inside_inline_layout(layout_str,&block)
  end
end
