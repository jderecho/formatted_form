module FormattedForm
  
  def self.prepend_required_mark=(required_mark_value)
    @prepend_required_mark = PrependRequiredMarkupConfig.new(required_mark_value) if required_mark_value
  end

  def self.prepend_required_mark
    @prepend_required_mark
  end

  protected

  class PrependRequiredMarkupConfig

    def initialize(required_mark_value)
      @required_mark_value = setup(required_mark_value)
    end

    def [](name)
      @required_mark_value[name]
    end

    private

    def setup(required_mark_value)
      if required_mark_value.is_a?(Hash)
        defaults(
            required_mark_value[:mark],
            required_mark_value[:tag],
            required_mark_value[:class]
          )
      elsif required_mark_value.is_a?(TrueClass)
        defaults
      else
        defaults(required_mark_value.to_s)
      end
    end

    def defaults(mark='*', tag=:span, css_class='control-label-required-mark')
      {tag: tag, mark: mark, class: css_class}
    end
  end
end
