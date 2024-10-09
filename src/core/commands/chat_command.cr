module Hisho
  class ChatCommand < Command
    def initialize(@input : String)
      super(:chat, "")
    end

    def execute(conversation_manager : ConversationManager, chat_client : ChatClient) : Command
      conversation_manager.add_user_message(@input)
      response = chat_client.send_message_to_ai(@input)
      if response
        conversation_manager.add_ai_response(response)
        @message = response
      else
        @type = :error
        @message = "Failed to get response from AI."
      end
      self
    end
  end
end
