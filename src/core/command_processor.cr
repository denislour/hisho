require "colorize"
require "file_utils"

module Hisho
  class CommandProcessor
    alias DisplayFunction = (String) -> Nil

    @@display_map : Hash(Symbol, DisplayFunction) = {
      :info => ->(message : String) { puts message.colorize(:green) },
      :error => ->(message : String) { puts message.colorize(:red) },
      :chat => ->(message : String) { puts "Hisho: #{message}".colorize(:blue) },
      :quit => ->(message : String) { puts message.colorize(:yellow) }
    }

    def execute(command : Command, conversation : Conversation, chat_client : ChatClient, file : File)
      result = command.execute(conversation, chat_client, file)
      display_result(result)
      result
    end

    private def display_result(result : Command)
      if display_proc = @@display_map[result.type]?
        display_proc.call(result.message)
      else
        puts "Unknown result type: #{result.type}"
      end
    end
  end
end
