require "./hisho/*"
require "dotenv"

Dotenv.load

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
        output.print "hisho> "
        command = input.gets.not_nil!.strip

        case command
        when .starts_with?("/quit"), .starts_with?("/q")
          output.puts "Goodbye!"
          return true
        when .starts_with?("/add"), .starts_with?("/a")
          paths = command.split[1..]
          if paths.empty?
            output.puts "Please provide at least one file or folder path.".colorize(:red)
          else
            Commands.add(paths, @added_files)
            puts @added_files.inspect
          end
        else
          @conversation, @last_ai_response = Commands.chat(command, @conversation, @last_ai_response)
        end
      end
      false
    end

    def print_available_commands
      puts "  Just type your message to chat with Hisho".colorize(:green)
      puts "  Available commands:".colorize(:blue)
      puts "    /add, a: Add files or folders to context (followed by paths)".colorize(:cyan)
      puts "    /quit: Exit the program".colorize(:red)
    end
  end

  def self.main
    exit if CLI.new.run
  end
end
