# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  CUSTOM_INPUT_CLASS = ["form-field"] #"col-xs-8", "col-sm-6"]

  config.wrappers :bootstrap, :tag => 'div', :class => 'form-group', :error_class => 'has-danger has-feedback' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper :tag => 'div', :class => CUSTOM_INPUT_CLASS do |ba|
      ba.use :input
      ba.use :feedback
      ba.use :error, :wrap_with => { :tag => 'span', :class => 'form-control-feedback' }
      ba.use :hint,  :wrap_with => { :tag => 'p', :class => 'form-control-feedback' }
    end
  end

  config.wrappers :prepend, :tag => 'div', :class => "form-group", :error_class => 'has-danger has-feedback' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper :tag => 'div', :class => CUSTOM_INPUT_CLASS do |input|
      input.wrapper :tag => 'div', :class => 'input-group' do |prepend|
        prepend.use :input
        prepend.use :feedback
      end
      input.use :error, :wrap_with => { :tag => 'span', :class => 'form-control-feedback' }
      input.use :hint,  :wrap_with => { :tag => 'span', :class => 'form-control-feedback' }
    end
  end

  config.wrappers :append, :tag => 'div', :class => "form-group", :error_class => 'has-danger has-feedback' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper :tag => 'div', :class => CUSTOM_INPUT_CLASS do |input|
      input.wrapper :tag => 'div', :class => 'input-group' do |append|
        append.use :input
        append.use :feedback
      end
      input.use :error, :wrap_with => { :tag => 'span', :class => 'form-control-feedback' }
      input.use :hint,  :wrap_with => { :tag => 'span', :class => 'form-control-feedback' }
    end
  end

  config.wrappers :checkbox, :tag => 'div', :class => 'form-group', :error_class => 'has-danger has-feedback' do |b|
    b.wrapper :tag => 'div', :class => CUSTOM_INPUT_CLASS + ["form-field-label"]do |ba|
      ba.use :label_input, :wrap_with => { :class => 'checkbox inline' }
      ba.use :feedback
      # FIXME where to place hint in a checkbox
      ba.use :error, :wrap_with => { :tag => 'span', :class => 'form-control-feedback' }
      ba.use :hint,  :wrap_with => { :tag => 'span', :class => 'form-control-feedback' }
    end
  end

  config.wrappers :inline_checkbox, :tag => 'div', :class => 'form-group', :error_class => 'has-danger has-feedback' do |b|
    b.wrapper :tag => 'div', :class => CUSTOM_INPUT_CLASS + ["form-field-label"] do |ba|
      ba.use :label_input
      ba.use :feedback
    end
  end

  config.wrappers :inline_checkbox_ori, :error_class => 'has-danger has-feedback' do |b|
    b.use :label_input, :wrap_with => { :class => 'checkbox-inline' }
    b.use :feedback
  end

  # Wrappers for forms and inputs using the Twitter Bootstrap toolkit.
  # Check the Bootstrap docs (http://twitter.github.com/bootstrap)
  # to learn about the different styles for forms and inputs,
  # buttons and other elements.
  config.default_wrapper = :bootstrap
end
