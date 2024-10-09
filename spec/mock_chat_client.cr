class MockChatClient < Hisho::ChatClient
  def initialize(@response : String)
  end

  def send_message_to_ai(user_message : String) : String?
    @response
  end
end
