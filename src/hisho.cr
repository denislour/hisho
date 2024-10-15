require "./core/chat_client"
require "./core/conversation"
require "./core/command_processor"
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
      @command_processor = CommandProcessor.new
      @chat_client = DefaultChatClient.new(ENV["OPENROUTER_API_KEY"], ENV["MODEL"])
      @runable = true
    end

    def run(input : IO = STDIN, output : IO = STDOUT) : Bool
      greetings(output)

      while @runable
        output.print "Hisho> "
        command_input = input.gets.not_nil!.strip
        command = CommandBuilder.build(command_input)
        command_result = @command_processor.execute(command, @conversation, @chat_client, @file)
        if command_result.type == :quit
          @runable = false
        end
      end
      true
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
