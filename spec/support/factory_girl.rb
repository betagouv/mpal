require 'factory_girl'

RSpec.configure do |config|
  # Include FactoryGirl so we can use 'create' instead of 'FactoryGirl.create'
  config.include FactoryGirl::Syntax::Methods
end
