module Hisho
  class AddCommand < Command
    def initialize(@paths : Array(String))
      super(:info, "")
    end

    def execute(conversation : Conversation, chat_client : ChatClient, file : File) : Command
      @paths.each do |path|
        return self if file.add_path(path) == :error
      end
      @message = "Added files: #{@paths.join(", ")}"
      self
    end

    def display
      puts @message.colorize(@type == :error ? :red : :green)
    end
  end
end
