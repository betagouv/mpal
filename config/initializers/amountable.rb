# Be sure to restart your server when you modify this file.
module Amountable
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def amountable(*args)
      args.each do |attribute|
        define_method "localized_#{attribute}" do
          ActiveSupport::NumberHelper.number_to_rounded(
              self[attribute.to_sym],
              precision: 2,
              delimiter: I18n.t('number.format.delimiter'),
              separator: I18n.t('number.format.separator'))
        end
        define_method "localized_#{attribute}=" do |arg|
          value = arg.gsub(I18n.t('number.format.delimiter'), '')
                     .gsub(I18n.t('number.format.separator'), '.')
          self[attribute.to_sym] = value
        end
      end
    end
  end
end

class ActiveRecord::Base
  include Amountable
end
