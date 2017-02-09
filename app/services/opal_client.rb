class OpalClient
  include HTTParty

  base_uri "#{ENV["OPAL_API_BASE_URI"]}sio/json"
  format :json
  headers 'Content-Type' => 'application/json' 
end
