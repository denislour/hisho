require "./commands/abstract_command"
require "./commands/*"

module Hisho
  class CommandBuilder
    alias CommandFunction = (Array(String)) -> Command

    @@command_map : Hash(String, CommandFunction) = {
      "quit" => ->(args : Array(String)) : Command { QuitCommand.new },
      "q" => ->(args : Array(String)) : Command { QuitCommand.new },
      "help" => ->(args : Array(String)) : Command { HelpCommand.new },
      "h" => ->(args : Array(String)) : Command { HelpCommand.new },
      "clear" => ->(args : Array(String)) : Command { ClearCommand.new },
      "show_context" => ->(args : Array(String)) : Command { ShowContextCommand.new },
      "add" => ->(args : Array(String)) : Command { AddCommand.new(args) },
      "a" => ->(args : Array(String)) : Command { AddCommand.new(args) }
    }

    def self.build(input : String) : Command
      parts = input.split
      command = parts.first.try(&.downcase.gsub("/", ""))
      args = parts[1..]

      if command && @@command_map.has_key?(command)
        @@command_map[command].call(args)
      else
        ChatCommand.new(input)
      end
    end
  end
end
