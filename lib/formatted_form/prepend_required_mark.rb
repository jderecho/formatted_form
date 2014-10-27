module FormattedForm

  def self.prepend_required_mark=(config)
    @prepend_required_mark_global_config = config
  end

  protected

  def self.prepend_required_mark(options={})
    PrependRequiredMarkupConfig.new(options, @prepend_required_mark_global_config)
  end

  class PrependRequiredMarkupConfig

    def initialize(options, global_config)
      @options = options
      @global_tag_values = init_global_tag_values(global_config)
      @tag_values = init_tag_values(options[:prepend_required_mark])
    end

    def required?
      (@global_tag_values.present? || @tag_values.present?) && (is_field_has_required_validation? || has_required_attribute? || options[:prepend_required_mark].present?)
    end

    def text
      @tag_values[:text]
    end

    def tag
      @tag_values[:tag]
    end

    def css_class
      @tag_values[:css_class]
    end

    private

    def options
      @options
    end

    def is_field_has_required_validation?
      obj = options[:builder].object
      method = options[:method]
      target = (obj.class == Class) ? obj : obj.class
      target.validators_on(method).select { |v| v.is_a?(ActiveModel::Validations::PresenceValidator) }.length > 0
    rescue
      false
    end

    def has_required_attribute?
      options[:content].include?(%{required="required"})
    end

    def init_global_tag_values(config)
      if config.is_a?(String)
        default_tag_values(config)
      elsif config.is_a?(Hash)
        default_tag_values(config[:text], config[:tag], config[:css_class])
      elsif config.is_a?(TrueClass)
        default_tag_values
      else
        nil
      end
    end

    def init_tag_values(config)
      if config.is_a?(String)
        if @global_tag_values.present?
          default_tag_values(config, @global_tag_values[:tag], @global_tag_values[:css_class])
        else
          default_tag_values(config)
        end
      elsif config.is_a?(Hash)
        if @global_tag_values.present?
          default_tag_values(config[:text] || @global_tag_values[:text], 
                   config[:tag] || @global_tag_values[:tag], 
                   config[:css_class] || @global_tag_values[:css_class]
                  )
        else
          default_tag_values(config[:text], config[:tag], config[:css_class])
        end
      elsif config.is_a?(TrueClass)
        @global_tag_values || default_tag_values
      elsif (config.nil? || config.is_a?(FalseClass)) && @global_tag_values.present?
        @global_tag_values
      end
    end

    def default_tag_values(text='*', tag=:span, css_class='control-label-required-mark')
      {text: text, tag: tag, css_class: css_class}
    end
  end
end