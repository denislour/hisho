module Hisho
  abstract class Command
    property type : Symbol
    property message : String

    def initialize(@type : Symbol, @message : String)
    end

    abstract def execute(conversation : Conversation, chat_client : ChatClient, file : File) : Command
  end
end
