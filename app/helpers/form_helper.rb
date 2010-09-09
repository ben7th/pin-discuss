module FormHelper

  def _deal_form_args(*args)
    object_or_array = args.first
    object = object_or_array.is_a?(Array) ? object_or_array.last : object_or_array

    options = args.extract_options!.merge(:builder => MindpinFormBuilder)
    options[:html] ||= {}

    css_classes = options[:html][:class] || ''

    html_options =
      if object.respond_to?(:new_record?) && object.new_record?
        { :class  => "common_form #{dom_class(object, :new)} #{css_classes}" }
      else
        { :class  => "common_form #{dom_class(object, :edit)} #{css_classes}" }
      end

    options[:html].merge!(html_options)
    
    options
  end

  def mindpin_form_for(*args, &block)
    options = _deal_form_args(*args)
    form_for(*(args + [options]), &block)
  end

  def mindpin_remote_form_for(*args, &block)
    options = _deal_form_args(*args)
    remote_form_for(*(args + [options]), &block)
  end

  def flash_notice(style='flash-notice')
    re=''
    if !flash[:notice].blank?
      re="<div class='#{style}'>#{flash[:notice]}</div>"
    end
    return re
  end

  def flash_error(style='flash-error')
    re=''
    if !flash[:error].blank?
      re="<div class='#{style}'>#{flash[:error]}</div>"
    end
    return re
  end

  def flash_success(style='flash-success')
    re=''
    if !flash[:success].blank?
      re="<div class='#{style}'>#{flash[:success]}</div>"
    end
    return re
  end

  def flash_info
    flash_notice + flash_error + flash_success
  end
end
