# Be sure to restart your server when you modify this file.
module Amountable
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def amountable(*args)
      args.each do |attribute|
        define_method attribute do
          self[attribute.to_sym].to_s.gsub(/[^.0-9]/,'').gsub('.', ',')
        end
        define_method "#{attribute}=" do |arg|
          self[attribute.to_sym] = arg.gsub(/[^,0-9]/,'').gsub(',', '.')
        end
      end
    end
  end
end

class ActiveRecord::Base
  include Amountable
end
