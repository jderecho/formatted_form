class BootstrapBuilder::FormBuilder < ActionView::Helpers::FormBuilder
    
  %w(
    text_field 
    password_field 
    email_field
    telephone_field
    phone_field
    number_field
    text_area 
    file_field 
    range_field
    search_field
  ).each do |field_name|
    define_method field_name do |method, *args|
      options = args.detect { |a| a.is_a?(Hash) } || {}
      html_options = collect_html_options(options)
      render_field(field_name, method, options, html_options) { super(method, options) } 
    end
  end

  %w{
    datetime_select 
    date_select 
    time_select 
    time_zone_select
  }.each do |field_name|
    define_method field_name do |method, options = {}, html_options = {}|
      render_field('select', method, options, html_options) do
        super(method, options, html_options)
      end
    end
  end

  def select(method, choices, options = {}, html_options = {})
    render_field('select', method, options, html_options) { super(method, choices, options, html_options) } 
  end

  def hidden_field(method, options = {}, html_options = {})
    super(method, options)
  end

  def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
    html_options = collect_html_options(options)
    if options[:values].present?
      values = options.delete(:values).collect do |key, val|
        name = "#{object_name}[#{method}][]"
        id = "#{object_name}_#{method}_#{val.to_s.gsub(' ', '_').underscore}"
        {
          :field => super(method, options.merge({:name => name, :id => id}), val, nil),
          :label_text => key,
          :id => id
        }
      end
      @template.render(:partial => "#{BootstrapBuilder.config.template_folder}/check_box", :locals  => {
        :builder => self,
        :method => method,
        :values => values,
        :label_text => label_text(method, options.delete(:label)),
        :help_block => @template.raw(options.delete(:help_block)),
        :error_messages => error_messages_for(method)
      })
    else
      render_field('check_box', method, options, html_options) do
        super(method, options, checked_value, unchecked_value)
      end
    end
  end

  def radio_button(method, tag_value, options = {})
    case tag_value
      when Array
        choices = tag_value.collect do |choice|
          if !choice.is_a?(Array)
            choice = [choice, choice]
          elsif choice.length == 1
            choice << choice[0]
          end
          {
            :field => super(method, choice[1], options),
            :label => choice[0],
            :id => "#{object_name}_#{method}_#{choice[1].to_s.gsub(' ', '_').underscore}"
          }
        end
      else
        choices = [{
          :field => super(method, tag_value),
          :label => tag_value,
          :label_for => "#{object_name}_#{method}_#{tag_value.to_s.gsub(' ', '_').underscore}"
        }]
    end
    
    @template.render(:partial => "#{BootstrapBuilder.config.template_folder}/radio_button", :locals  => {
      :builder => self,
      :method => method,
      :label_text => label_text(method, options.delete(:label)),
      :choices => choices,
      :required => options.delete(:required),
      :before_text => @template.raw(options.delete(:before_text)),
      :after_text => @template.raw(options.delete(:after_text)),
      :help_block => @template.raw(options.delete(:help_block)),
      :error_messages => error_messages_for(method)
    })
  end
  
  # Creates submit button element with appropriate bootstrap classes.
  # If `onsubmit_value` option is passed button will be disabled to prevent
  # multiple form submissions. Example:
  #   form.submit, :class => 'btn-danger'
  #   form.submit 'Create User', :onsubmit_value => 'Creating...'
  def submit(value = nil, options = {}, &block)
    value, options = nil, value if value.is_a?(Hash)
    value ||= submit_default_value
    
    # Add specific bootstrap class
    options[:class] = "#{options[:class]} btn".strip
    options[:class] = "#{options[:class]} btn-primary" unless options[:class] =~ /btn-/
    
    # Button can be set to be disabled when form is submitted
    if onsubmit_value = options.delete(:onsubmit_value)
      options[:data] ||= { }
      options[:data][:onsubmit_value]  = onsubmit_value
      options[:data][:offsubmit_value] = value
    end
    
    @template.render(:partial => "#{BootstrapBuilder.config.template_folder}/submit", :locals  => {
      :builder  => self,
      :field    => super(value, options)
    })
  end
  
  # generic container for all things form
  def element(label = '&nbsp;', value = '', type = 'text_field', &block)
    value += @template.capture(&block) if block_given?
    %{
      <div class='control-group'>
        <label class='control-label'>#{label}</label>
        <div class='controls'>
          #{value}
        </div>
      </div>
    }.html_safe
  end

  def error_messages
    if object && !object.errors.empty?
      message = object.errors[:base].present? ? object.errors[:base]: 'There were some problems submitting this form. Please correct all the highlighted fields and try again'
      @template.content_tag(:div, message, :class => 'form_error')
    end
  end

  def error_messages_for(method)
    if (object and object.respond_to?(:errors) and errors = object.errors[method] and !errors.empty?)
      errors.is_a?(Array) ? errors.first : errors
    end
  end

  def fields_for(record_or_name_or_array, *args, &block)
    options = args.extract_options!
    options[:builder] ||= BootstrapBuilder::FormBuilder
    options[:html] ||= {}
    options[:html][:class] ||= self.options[:html] && self.options[:html][:class]
    super(record_or_name_or_array, *(args << options), &block)
  end

  
protected
  
  # Main rendering method
  def render_field(field_name, method, options={}, html_options={}, &block)
    case field_name
    when 'check_box'
      template = field_name
    else
      template = 'default_field'
    end
    @template.render(:partial => "#{BootstrapBuilder.config.template_folder}/#{template}", :locals  => {
      :builder        => self,
      :method         => method,
      :field          => @template.capture(&block),
      :label_text     => label_text(method, html_options[:label]),
      :required       => html_options[:required],
      :prepend        => html_options[:prepend],
      :append         => html_options[:append],
      :help_block     => html_options[:help_block],
      :error_messages => error_messages_for(method)
    })
  end

  def label_text(method, text = nil)
    text.nil? ? method.to_s.titleize.capitalize : @template.raw(text)
  end
  
  def collect_html_options(options = {})
    [
      :prepend, 
      :append, 
      :label, 
      :help_block,
      :required
    ].inject({}) do |h, attribute|
      h[attribute] = @template.raw(options.delete(attribute)) if options[attribute]
      h
    end
  end
end