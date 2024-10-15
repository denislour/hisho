module Hisho
  class AddCommand < Command
    def initialize(@paths : Array(String))
      super(:info, "")
    end

    def execute(conversation : Conversation, chat_client : ChatClient, file : File) : Command
      @paths.each do |path|
        result = file.add_path(path)
        if result == :error
          @type = :error
          @message = "Error: #{path} is not a file or directory."
          return self
        end
      end
      @message = "Added files: #{@paths.join(", ")}"
      self
    end

    def display
      puts @message.colorize(@type == :error ? :red : :green)
    end
  end
end
