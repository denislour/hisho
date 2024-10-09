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
      @runable = true
      Commands.setup(ENV["OPENROUTER_API_KEY"], ENV["MODEL"])
    end

    def run(input : IO = STDIN, output : IO = STDOUT) : Bool
      greetings(output)

      while @runable
        output.print "Hisho> "
        command = input.gets.not_nil!.strip
        handle_command(command, output)
      end
      true
    end

    private def handle_command(command : String, output : IO) : Nil
      command_parts = command.split
      action = command_parts.first?
      args = command_parts[1..]

      case action
      when "/quit", "/q"
        output.puts "Goodbye!"
        @runable = false
      when "/add", "/a"
        Commands.add(args, @added_files, output)
      when "/clear"
        @conversation, @added_files, @last_ai_response = Commands.clear(@conversation, @added_files, @last_ai_response, output)
      when "/show_context"
        Commands.show_context(@conversation, @added_files, output)
      when "/help", "/h"
        show_help(output)
      else
        @conversation, @last_ai_response = Commands.chat(command, @conversation, @last_ai_response, output)
      end
    end

    private def show_help(output : IO) : Nil
      output.puts "Available commands:".colorize(:blue)
      output.puts "  /add, a: Add files or folders to context (followed by paths)".colorize(:cyan)
      output.puts "  /clear: Clear chat context and added files".colorize(:cyan)
      output.puts "  /show_context: Show current conversation and added files".colorize(:cyan)
      output.puts "  /help, h: Show this help message".colorize(:cyan)
      output.puts "  /quit: Exit the program".colorize(:red)
    end

    private def greetings(output : IO) : Nil
      output.puts "Welcome to Hisho!".colorize(:green)
      output.puts "I'm here to assist you with your tasks and answer your questions.".colorize(:green)
      output.puts "Feel free to start chatting or use one of the available commands.".colorize(:green)
      output.puts "Type '/help' or '/h' to see the list of commands.".colorize(:green)
      output.puts
    end
  end

  def self.main : Nil
    exit unless CLI.new.run
  end
end
