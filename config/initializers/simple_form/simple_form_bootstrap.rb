# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  CUSTOM_INPUT_CLASS = ["form-field"] #"col-xs-8", "col-sm-6"]

  config.wrappers :bootstrap, tag: "div", class: "form-group", error_class: "has-danger has-feedback" do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper tag: "div", class: CUSTOM_INPUT_CLASS do |input|
      input.use :input
      input.use :feedback
      input.use :error, wrap_with: { tag: "span", class: "form-control-feedback" }
      input.use :hint,  wrap_with: { tag: "small", class: "form-text text-muted" }
    end
  end

  config.wrappers :prepend, tag: "div", class: "form-group", error_class: "has-danger has-feedback" do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper tag: "div", class: CUSTOM_INPUT_CLASS do |input|
      input.wrapper tag: "div", class: "input-group" do |prepend|
        prepend.use :input
        prepend.use :feedback
      end
      input.use :error, wrap_with: { tag: "span", class: "form-control-feedback" }
      input.use :hint,  wrap_with: { tag: "small", class: "form-text text-muted" }
    end
  end

  config.wrappers :append, tag: "div", class: "form-group", error_class: "has-danger has-feedback" do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.wrapper tag: "div", class: CUSTOM_INPUT_CLASS do |input|
      input.wrapper tag: "div", class: "input-group" do |append|
        append.use :input
        append.use :feedback
      end
      input.use :error, wrap_with: { tag: "span", class: "form-control-feedback" }
      input.use :hint,  wrap_with: { tag: "small", class: "form-text text-muted" }
    end
  end

  config.wrappers :booleans, tag: "div", class: "form-group", error_class: "has-danger has-feedback" do |b|
    b.wrapper tag: "div", class: "form-check-hacked" do |input|
      input.use :label_input, class: "form-check-input"
    end
    b.use :feedback
    b.use :error, wrap_with: { tag: "span", class: "form-control-feedback" }
    b.use :hint,  wrap_with: { tag: "small", class: "form-text text-muted" }
  end

  config.wrappers :inline_checkbox, tag: "div", class: "form-group", error_class: "has-danger has-feedback" do |b|
    b.wrapper tag: "div", class: CUSTOM_INPUT_CLASS + ["form-field-label"] do |input|
      input.use :label_input
      input.use :feedback
    end
  end

  config.wrappers :vertical_boolean, tag: "div", class: "form-group", error_class: "has-danger has-feedback" do |b|
    b.wrapper tag: "div", class: CUSTOM_INPUT_CLASS + ["form-field-label"] do |input|
      input.use :label_input
      input.use :feedback
    end
  end

  config.wrapper_mappings = {
    check_boxes:   :booleans,
    radio_buttons: :booleans,
    file:          :vertical_file_input,
    boolean:       :vertical_boolean,
  }
end
