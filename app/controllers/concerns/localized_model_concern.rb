module LocalizedModelConcern
  extend ActiveSupport::Concern

  module ClassMethods
    # Définit un setter qui convertit des nombres localisés en nombres US (parsables par Ruby).
    # Exemple : "100,25" -> "100.25"
    def localized_numeric_setter(attribute)
      raise "Attribute '#{attribute}' is not among the attributes of the model" unless attribute_names.include?(attribute.to_s)
      define_method :"#{attribute}=" do |value|
        write_attribute(attribute, value.gsub(I18n.t('number.format.separator'), '.'))
      end
    end
  end
end
