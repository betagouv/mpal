module SimpleForm
  module Components
    module Feedbacks
      def feedback(wrapped_options)
        @feedback ||= begin
          if has_feedback?
            template.content_tag(:span, '', class: "glyphicon glyphicon-remove form-control-feedback")
          end
        end
      end

      def has_feedback?
        respond_to?(:has_errors?) && has_errors?
      end
    end
  end
end

SimpleForm::Inputs::Base.send(:include, SimpleForm::Components::Feedbacks)
