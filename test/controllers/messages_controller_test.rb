require "test_helper"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  test "should get receive" do
    get messages_receive_url
    assert_response :success
  end

  test "should get reply" do
    get messages_reply_url
    assert_response :success
  end
end
