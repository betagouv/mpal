class InstructionController < ApplicationController
	before_action :authenticate_agent!
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
