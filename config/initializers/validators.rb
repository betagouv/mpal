# Be sure to restart your server when you modify this file.
class EmailValidator < ActiveModel::EachValidator
  REG_EMAIL = Regexp.new( # The following pattern matches about 99.99% of actual uses.
      '^[a-z0-9!#$%&\'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&\'*+/=?^_`{|}~-]+)*' +
      '@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$', 'i')

  def validate_each(record, attribute, value)
    unless value =~ REG_EMAIL
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.invalid'))
    end
  end
end
