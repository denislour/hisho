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
      loop do
        output.print "hisho> "
        command = input.gets

        return true if command.nil?
        command = command.strip
        case command
        when "/quit"
          output.puts "Bye!"
          return true
        else
          @conversation, @last_ai_response = Commands.chat(command, @conversation, @last_ai_response)
        end
      end
      false
    end

    def print_available_commands
      puts "Available commands:".colorize(:blue)
      puts "  Just type your message to chat with Hisho"
      puts "  /quit: Exit the program"
    end
  end

  def self.main
    exit if CLI.new.run
  end
end
