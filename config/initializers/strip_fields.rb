# Be sure to restart your server when you modify this file.
module StripFields
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def strip_fields(*args)
      before_save do
        args.each do |column|
          tmp = self.send(column.to_s)
          self.send("#{column}=", tmp.strip) if tmp
        end
      end
    end
  end
end

class ActiveRecord::Base
  include StripFields
end
