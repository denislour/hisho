class MockChatClient < Hisho::ChatClient
  def initialize(@response : String)
  end

  def chat_with_ai(user_message : String) : String?
    @response
  end
end