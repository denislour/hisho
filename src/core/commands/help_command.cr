module Hisho
  class HelpCommand < Command
    HELP_MESSAGE = <<-HELP
      Available commands:
      /add, /a [path]: Add files or folders to context
      /clear: Clear chat context and added files
      /show_context: Show current conversation and added files
      /help, /h: Show this help message
      /quit, /q: Exit the program
      HELP

    def initialize
      super(:info, HELP_MESSAGE)
    end

    def execute(conversation : Conversation, chat_client : ChatClient, file : File) : Command
      self
    end

    def display
      puts @message.colorize(:green)
    end
  end
end
