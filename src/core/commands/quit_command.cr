module Hisho
  class QuitCommand < Command
    def initialize
      super(:quit, "Goodbye!")
    end

    def execute(conversation_manager : ConversationManager, chat_client : ChatClient) : Command
      self
    end
  end
end
