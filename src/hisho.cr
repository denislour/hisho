require "./core/chat_client"
require "./core/conversation"
require "./core/command_builder"
require "./core/file"
require "dotenv"
require "colorize"

Dotenv.load if File.exists?(".env")

module Hisho
  VERSION = "0.1.0"

  class CLI
    def initialize
      @conversation = Conversation.new
      @file = File.new
      @chat_client = DefaultChatClient.new(ENV["OPENROUTER_API_KEY"], ENV["MODEL"])
      @running = true
    end

    def run(input : IO = STDIN, output : IO = STDOUT) : Bool
      display_greeting(output)
      main_loop(input, output)
      true
    end

    private def display_greeting(output : IO)
      [
        "Welcome to Hisho!",
        "I'm here to assist you with your tasks and answer your questions.",
        "Feel free to start chatting or use one of the available commands.",
        "Type '/help' or '/h' to see the list of commands.",
        ""
      ].each { |line| output.puts line.colorize(:green) }
    end

    private def main_loop(input : IO, output : IO)
      while @running
        output.print "Hisho> "
        break unless handle_input(input.gets)
      end
    end

    private def handle_input(input : String?) : Bool
      return false if input.nil?

      command = CommandBuilder.build(input.strip)
      result = command.execute(@conversation, @chat_client, @file)
      result.display
      @running = false if result.type == :quit
      true
    end
  end

  def self.main : Nil
    exit unless CLI.new.run
  end
end
