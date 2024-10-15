module Hisho
  class ChatCommand < Command
    def initialize(@input : String)
      super(:chat, "")
    end

    def execute(conversation : Conversation, chat_client : ChatClient, file : File) : Command
      conversation.add_user_message(@input)
      response = chat_client.send_message_to_ai(@input)
      if response
        conversation.add_ai_response(response)
        @message = response
      else
        @type = :error
        @message = "Failed to get response from AI."
      end
      self
    end

    def display
      puts "Hisho: #{@message}".colorize(:blue)
    end
  end
end
