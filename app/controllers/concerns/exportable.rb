module Exportable
  def csv_options
    { :col_sep => ";", :quote_char => '"', :force_quotes => false }
  end

  def csv_ouput_encoding
    Encoding::ISO_8859_1
  end
end
