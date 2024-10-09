module Hisho
  class ClearCommand < Command
    def initialize
      super(:info, "Chat context and added files have been cleared.")
    end

    def execute(conversation_manager : ConversationManager, chat_client : ChatClient) : Command
      conversation_manager.clear
      self
    end
  end
end
