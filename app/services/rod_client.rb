class RodClient
  include HTTParty

  base_uri "#{ENV["ROD_API_BASE_URI"]}"
  format :json
  headers "Authorization" => "Bearer #{ENV["ROD_API_KEY"]}"
end