module Hisho
  class ClearCommand < Command
    def initialize
      super(:info, "Cleared conversation and file context.")
    end

    def execute(conversation : Conversation, chat_client : ChatClient, file : File) : Command
      conversation.clear
      file.clear
      self
    end

    def display
      puts @message.colorize(:green)
    end
  end
end
