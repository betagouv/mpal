module CASClient
  module XmlResponse
    alias_method :check_and_parse_xml_normally, :check_and_parse_xml
    def check_and_parse_xml(raw_xml)
      raw_xml.force_encoding Encoding::ISO_8859_1
      cooked_xml = raw_xml.encode Encoding::UTF_8
      check_and_parse_xml_normally(cooked_xml)
    end
  end
end

