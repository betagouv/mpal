class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end

module CASClient
  module XmlResponse
    alias_method :check_and_parse_xml_normally, :check_and_parse_xml
    def check_and_parse_xml(raw_xml)
      cooked_xml = raw_xml.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
      check_and_parse_xml_normally(cooked_xml)
    end
  end
end
