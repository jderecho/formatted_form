class FormattedForm::FormBuilder < ActionView::Helpers::FormBuilder
    
  %w(
    text_field password_field email_field telephone_field number_field
    text_area file_field range_field search_field url_field
  ).each do |field_name|
    define_method field_name do |method, *args|
      options = args.detect { |a| a.is_a?(Hash) } || {}
      default_field(field_name, method, options) do
        super(method, *args)
      end
    end
  end

  %w(
    datetime_select date_select time_select
  ).each do |field_name|
    define_method field_name do |method, options = {}, html_options = {}|
      default_field(field_name, method, options) do
        super(method, options)
      end
    end
  end
  
  %w(
    time_zone_select
  ).each do |field_name|
    define_method field_name do |method, options = nil, html_options = {}|
      default_field(field_name, method, options) do
        super(method, options)
      end
    end
  end

  # Wrapper for the select field
  def select(method, choices, options = {}, html_options = {})
    default_field(:select, method, options) do 
      super(method, choices, options, html_options)
    end 
  end
  
  # Same as the old check box but it's possible to send an array of values
  #   form.check_box :color
  #   form.check_box :color, {}, 'white'
  #   form.check_box :color, {}, ['red', 'blue']
  #   form.check_box :color, {}, [['Red', 'red'], ['Blue', 'blue']]
  def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
    return super(method, options, checked_value, unchecked_value) if options.delete(:builder) == false
    is_array = checked_value.is_a?(Array)
    options.merge!(:multiple => true) if is_array
    checked_value = is_array ? checked_value : [[checked_value, checked_value, unchecked_value]]
    choices = checked_value.collect do |label, checked, unchecked|
      label, checked  = label, label          if !checked && is_array
      checked         = label                 if !checked
      label           = @object.class.human_attribute_name(method.to_s)  if !is_array
      
      match = super(method, options, checked, unchecked).match(/(<input .*?\/>)?(<input .*?\/>)/)
      hidden, input = match[1], match[2]
      [hidden.to_s.html_safe, input.to_s.html_safe, label]
    end
    default_field(:check_box, method, options.merge(:choices => choices))
  end
  
  # Radio button helper. Optionally it's possible to specify multiple choices at once:
  #   form.radio_button :role, 'admin'
  #   form.radio_button :role, ['admin', 'regular']
  #   form.radio_button :role, [['Admin', 1], ['Regular', 0]]
  def radio_button(method, tag_value, options = {})
    return super(method, tag_value, options) if options.delete(:builder) == false
    tag_values = tag_value.is_a?(Array) ? tag_value : [tag_value]
    choices = tag_values.collect do |label, choice|
      label, choice = label, label if choice.nil?
      [nil, super(method, choice, options), label]
    end
    default_field(:radio_button, method, options.merge(:choices => choices))
  end
  
  # Creates submit button element with appropriate bootstrap classes.
  #   form.submit, :class => 'btn-danger'
  def submit(value = nil, options = {}, &block)
    default_field(:submit, nil, options) do
      super(value, options)
    end
  end
  
  # Form helper to render generic content as a form field. For example:
  #   form.element 'Label', 'Content'
  #   form.element 'Label do
  #     Content
  #   end
  def element(label = false, value = nil, options = {}, &block)
    options = {:label => label, :content => value }
    default_field(:element, nil, options, &block)
  end
  
  # adding builder class for fields_for
  def fields_for(record_name, record_object = nil, options = {}, &block)
    options[:builder] ||= FormattedForm::FormBuilder
    super(record_name, record_object, options, &block)
  end
  
protected
  
  # Main rendering method
  def default_field(field_name, method, options = nil, &block)
    options ||= {}
    return yield if options.delete(:builder) == false && block_given?
    builder_options = builder_options!(options)
    @template.render(
      :partial => "formatted_form/#{field_name}",
      :locals  => { :options => builder_options.merge(
        :builder    => self,
        :field_name => field_name,
        :method     => method,
        :content    => block_given?? @template.capture(&block) : options.delete(:content),
        :errors     => method ? error_messages_for(method) : nil
      )}
    )
  end
  
  # Extacts parameters that are used for rendering the field
  def builder_options!(options = {})
    [
      :label, :prepend, :append, :prepend_html, :append_html, :help_block, :help_inline, :choices, :inline, :prepend_required_mark
    ].each_with_object({}) do |attr, hash|
      hash[attr] = options.delete(attr)
    end
  end
  
  # Collecting errors for a field and outputting first instance
  def error_messages_for(method)
    [object.errors[method]].flatten.first if object && object.respond_to?(:errors)
  end
end
