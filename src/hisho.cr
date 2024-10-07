require "./core/*"
require "dotenv"

Dotenv.load if File.exists?(".env")

module Hisho
  VERSION = "0.1.0"

  class CLI
    def initialize
      @conversation = [] of String
      @added_files = {} of String => String
      @last_ai_response = ""
      Commands.setup(ENV["OPENROUTER_API_KEY"], ENV["MODEL"])
    end

    def run(input : IO = STDIN, output : IO = STDOUT)
      print_available_commands

      loop do
        output.print "Hisho> "
        command = input.gets.not_nil!.strip
        return true if handle_command(command, output)
      end
      false
    end

    private def handle_command(command : String, output : IO) : Bool
      command_parts = command.split
      action = command_parts.first?
      args = command_parts[1..]

      case action
      when "/quit", "/q"
        output.puts "Goodbye!"
        true
      when "/add", "/a"
        Commands.add(args, @added_files, output)
        false
      when "/clear"
        Commands.clear(@conversation, @added_files, @last_ai_response, output)
        false
      when "/show_context"
        Commands.show_context(@conversation, @added_files, output)
        false
      else
        @conversation, @last_ai_response = Commands.chat(command, @conversation, @last_ai_response, output)
        false
      end
    end

    private def print_available_commands
      puts "  Just type your message to chat with Hisho".colorize(:green)
      puts "  Available commands:".colorize(:blue)
      puts "    /add, a: Add files or folders to context (followed by paths)".colorize(:cyan)
      puts "    /clear: Clear chat context and added files".colorize(:cyan)
      puts "    /show_context: Show current conversation and added files".colorize(:cyan)
      puts "    /quit: Exit the program".colorize(:red)
    end
  end

  def self.main
    exit if CLI.new.run
  end
end
