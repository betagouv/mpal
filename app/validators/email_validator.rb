class EmailValidator < ActiveModel::EachValidator
  REG_EMAIL = Regexp.new( # The following pattern matches about 99.99% of actual uses.
      '^[[:alnum:]!#$%&\'*+/=?^_`{|}~-]+(?:\.[[:alnum:]!#$%&\'*+/=?^_`{|}~-]+)*' +
      '@(?:[[:alnum:]](?:[[:alnum:]-]*[[:alnum:]])?\.)+[[:alnum:]](?:[[:alnum:]-]*[[:alnum:]])?$', 'i')

  def validate_each(record, attribute, value)
    unless value.blank? || value =~ REG_EMAIL
      record.errors.add(attribute, options[:message] || :invalid)
    end
  end
end
