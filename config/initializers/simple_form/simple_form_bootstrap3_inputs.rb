# encoding: utf-8
inputs = %w[
  CollectionSelectInput
  DateTimeInput
  FileInput
  GroupedCollectionSelectInput
  NumericInput
  PasswordInput
  RangeInput
  StringInput
  TextInput
]

inputs.each do |input_type|
  superclass = "SimpleForm::Inputs::#{input_type}".constantize

  new_class = Class.new(superclass) do
    def input_html_classes
      s = super
      s.map!(&:to_s)
      s.push('form-control') unless s.include?('form-control')
      s
    end
  end

  Object.const_set(input_type, new_class)
end
