require 'vonage'

VONAGE_CLIENT = Vonage::Client.new(
  api_key: ENV['VONAGE_API_KEY'],
  api_secret: ENV['VONAGE_API_SECRET']
)
