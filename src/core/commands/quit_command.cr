module Hisho
  class QuitCommand < Command
    def initialize
      super(:quit, "Goodbye!")
    end

    def execute(conversation : Conversation, chat_client : ChatClient, file : File) : Command
      self
    end
  end
end
