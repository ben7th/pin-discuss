class MindpinFormBuilder < ActionView::Helpers::FormBuilder
  def self.create_builder(method_name,htmlclass='text')
    define_method(method_name) do |label,*args|
      options = args.first
      options||={}
      args = [options] if args.blank?
      options[:class] = push_classname(options[:class],htmlclass)
      show_label = options.delete :show_label
      show_label = true if show_label.nil?
      # rails 2.3.8 中 content_tag 返回 ActiveSupport::SafeBuffer 类型
      # 它重载了 字符串的 + 方法，会将 + 后的字符串 进行 escapeHTML
      # 所以用 + 方法 要注意
      label_html = (show_label ?
        @template.content_tag("label",
          I18n.t("activerecord.attributes.#{@object_name}.#{label}"),
          :for=>"#{@object_name}_#{label}"
        ) : '')
      @template.content_tag("div",
        "#{label_html}" + super(label,*args) + fielderror(@object,label),
        :class=>'p'
      )
    end
  end

  create_builder(:text_field)
  create_builder(:password_field)
  create_builder(:text_area,'')
  create_builder(:file_field,'')

  def select(label,choices,*args)
    @template.content_tag("div",
      @template.content_tag("label",
        I18n.t("activerecord.attributes.#{@object_name}.#{label}"),
        :for=>"#{@object_name}_#{label}"
      ) + super(label,choices,*args) + fielderror(@object,label),
      :class=>'p'
    )
  end

  def radio_button_with_text(label,text='',*args)
    @template.content_tag("div",
      [
        ActionView::Helpers::FormBuilder.instance_method("radio_button").bind(self).call(label,*args),
        "<span class='margin10'>#{text}</span>",
        fielderror(@object,label)
      ],
      :class=>'p indent'
    )
  end

  def submit(value,*args)
    if args.blank?
      args = [{:class=>'ui-button'}]
    end
    @template.content_tag("div",
      @template.content_tag("span",
        super(value,*args),
        :class=>'ui-button-span'
      ),
      :class=>'p'
    )
  end

  def submit_with_cancel(value,return_url=nil,*args)
    if args.blank?
      args = [{:class=>'btn'}]
    end
    @template.content_tag("div",
      [
        ActionView::Helpers::FormBuilder.instance_method("submit").bind(self).call(value,*args),
        "<a href='#{return_url}' class='margin10'>取消</a>"
      ]
    )
  end

  private
    def push_classname(class_names_str,classname)
      class_names_str ||= ''
      (class_names_str.split(' ')<<classname).uniq*' '
    end

    def fielderror(model,field)
      if model.blank?
        return ''
      else
        re=[]
        re<<model.errors[field]
        re = re.flatten[0]
        return "<span class='fielderror'>#{re}</span>"
      end
    end
end
