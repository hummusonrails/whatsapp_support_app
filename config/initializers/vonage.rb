require 'vonage'

VONAGE_CLIENT = Vonage::Client.new(
  api_key: ENV['VONAGE_API_KEY'],
  api_secret: ENV['VONAGE_API_SECRET'],
  application_id: ENV['VONAGE_APPLICATION_ID'],
  private_key: File.read(ENV['VONAGE_PRIVATE_KEY_PATH'])
)
