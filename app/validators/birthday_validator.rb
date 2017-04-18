class BirthdayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present? && value > Date.today
      record.errors.add(attribute, options[:message] || :not_in_past)
    end
  end
end
