module Hisho
  abstract class Command
    property type : Symbol
    property message : String

    def initialize(@type : Symbol, @message : String)
    end

    abstract def execute(conversation_manager : ConversationManager, chat_client : ChatClient) : Command
  end
end
