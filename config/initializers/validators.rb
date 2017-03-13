# Be sure to restart your server when you modify this file.
class EmailValidator < ActiveModel::EachValidator
  REG_EMAIL = Regexp.new( # The following pattern matches about 99.99% of actual uses.
      '^[a-z0-9!#$%&\'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&\'*+/=?^_`{|}~-]+)*' +
      '@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$', 'i')

  def validate_each(record, attribute, value)
    unless value.blank? || value =~ REG_EMAIL
      record.errors.add(attribute, options[:message] || :invalid)
    end
  end
end

class PhoneValidator < ActiveModel::EachValidator
  # This validator loosely checks if the phone number contains the required number of digits.
  # It doesn't attempt to normalize or format the phone number.
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
