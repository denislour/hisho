module Hisho
  class ChatCommand < Command
    def initialize(@input : String)
      super(:chat, "")
    end

    def execute(conversation : Conversation, chat_client : ChatClient, file : File) : Command
      conversation.add_user_message(@input)
      @message = chat_client.send_message_to_ai(@input) || "Failed to get response from AI."
      @type = @message.starts_with?("Failed") ? :error : :chat
      conversation.add_ai_response(@message) if @type == :chat
      self
    end

    def display
      puts "Hisho: #{@message}".colorize(@type == :error ? :red : :blue)
    end
  end
end
