# Be sure to restart your server when you modify this file.
class BigNumberValidator < ActiveModel::EachValidator
  NUMBER_LIMITED_TO_8_DIGITS_REGEXP = /^\d{1,8}(,?\d*)?$/

  def validate_each(record, attribute, value)
    localized_value = record.send("localized_#{attribute}").to_s.gsub(/\s+/, "")
    unless localized_value == "" || localized_value =~ NUMBER_LIMITED_TO_8_DIGITS_REGEXP
      record.errors.add(attribute, "doit être inférieur à '100 000 000'")
    end
  end
end
