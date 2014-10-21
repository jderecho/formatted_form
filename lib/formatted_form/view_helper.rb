module FormattedForm::ViewHelper
  
  def formatted_form_for(record, options = {}, &proc)
    options = options.dup
    options[:builder] ||= FormattedForm::FormBuilder
    
    options[:html] ||= { }
    options[:html][:class] ||= 'formatted'
    
    # :type option will set proper form class. Conversely having
    # proper css class will set the type that controls what html
    # wrappers are used to render form fields
    if type = options[:html][:class].match(/form-(inline|horizontal|search)/)
      options[:type] ||= type[1].try(:to_sym)
    
    elsif options[:type].present?
      form_class = case options[:type]
        when :inline      then 'form-inline'
        when :horizontal  then 'form-horizontal'
        when :search      then 'form-search'
      end
      options[:html][:class] = "#{options[:html][:class]} #{form_class}".strip
    end
    options[:type] ||= :vertical
    options[:type] = options[:type].to_sym
    
    form_for(record, options, &proc)
  end

  protected

  def required?(obj, attr)
    target = (obj.class == Class) ? obj : obj.class
    target.validators_on(attr).select { |v| v.is_a?(ActiveModel::Validations::PresenceValidator) }.length > 0
  end
  
end
