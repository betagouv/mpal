require 'dotenv'
RSpec.configure do |config|
  config.before(:each) do
    FakeWeb.register_uri(
      :post,  %r|#{ENV['OPAL_API_BASE_URI']}/createDossier|,
      content_type: 'application/json',
      body: JSON.generate({
        "dosNumero": "09500840",
        "dosId": 959496
      })
    )
  end
end
