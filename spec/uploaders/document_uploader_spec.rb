require "rails_helper"

describe DocumentUploader do
  let(:uploader) { DocumentUploader.new }

  it "has the correct format" do
    extension_whitelist = uploader.extension_whitelist

    # Texts
    expect(extension_whitelist).to include "txt"
    expect(extension_whitelist).to include "docx"
    expect(extension_whitelist).to include "doc"
    expect(extension_whitelist).to include "dot"
    expect(extension_whitelist).to include "rtf"
    expect(extension_whitelist).to include "pdf"

    # Tables
    expect(extension_whitelist).to include "csv"
    expect(extension_whitelist).to include "xlsx"
    expect(extension_whitelist).to include "xls"
    expect(extension_whitelist).to include "xlt"
    expect(extension_whitelist).to include "odt"
    expect(extension_whitelist).to include "ott"
    expect(extension_whitelist).to include "ods"
    expect(extension_whitelist).to include "ots"

    # Images
    expect(extension_whitelist).to include "jpg"
    expect(extension_whitelist).to include "jpeg"
    expect(extension_whitelist).to include "gif"
    expect(extension_whitelist).to include "png"
    expect(extension_whitelist).to include "tiff"
    expect(extension_whitelist).to include "tga"
    expect(extension_whitelist).to include "svg"
  end

  it "has a size limit" do
    expect(uploader.size_range).to eq 0..10.megabyte
  end
end