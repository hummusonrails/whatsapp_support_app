require 'webmock/rspec'

module WhatsappMock
  def self.included(base)
    base.before do
      mock_whatsapp_api
    end
  end

  def mock_whatsapp_api
    WebMock.stub_request(:post, /api\.vonage\.com\/v1\/messages/).to_return(
      status: 200,
      body: '{"message_uuid":"mocked-uuid"}',
      headers: { 'Content-Type' => 'application/json' }
    )
  end
end
