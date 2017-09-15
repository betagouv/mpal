FactoryGirl.define do
  factory :document do
    fichier { Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/Ma pièce jointe.txt'))) }
    type_piece :autres_projet
  end
end
