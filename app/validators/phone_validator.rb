# This validator loosely checks if the phone number contains the required number of digits.
# It doesn't attempt to normalize or format the phone number.
class PhoneValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    numbers = value.gsub(/[^0-9]/, '')
    minimum_numbers = options[:minimum] || 10
    maximum_numbers = options[:maximum] || 12

    if value.present?
      if numbers.length < minimum_numbers
        record.errors.add(attribute, options[:message] || :too_short, { count: minimum_numbers })
      elsif numbers.length > maximum_numbers
        record.errors.add(attribute, options[:message] || :too_long, { count: maximum_numbers })
      end
    end
  end
end
