module Hisho
  class ClearCommand < Command
    def initialize
      super(:info, "Chat context and added files have been cleared.")
    end

    def execute(conversation : Conversation, chat_client : ChatClient, file : File) : Command
      conversation.clear
      file.clear
      self
    end
  end
end
