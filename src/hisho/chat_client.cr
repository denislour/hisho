module Hisho
  abstract class ChatClient
    abstract def chat_with_ai(user_message : String) : String?
  end

  class DefaultChatClient < ChatClient
    def chat_with_ai(user_message : String) : String?
      Commands.chat_with_ai(user_message)
    end
  end
end