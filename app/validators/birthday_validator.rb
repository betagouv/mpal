class BirthdayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.blank? || value > Date.today
      record.errors.add(attribute, options[:message] || :invalid)
    end
  end
end
