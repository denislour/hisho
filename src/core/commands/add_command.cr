module Hisho
  class AddCommand < Command
    def initialize(@paths : Array(String))
      super(:info, "")
    end

    def execute(conversation : Conversation, chat_client : ChatClient, file : File) : Command
      added_files = [] of String
      @paths.each do |path|
        if ::File.file?(path)
          file.add(path, ::File.read(path))
          added_files << path
        elsif Dir.exists?(path)
          file.add_directory(path)
          added_files << "#{path} (directory)"
        else
          @type = :error
          @message = "Error: #{path} is not a file or directory."
          return self
        end
      end
      @message = "Added files: #{added_files.join(", ")}"
      self
    end

    def display
      if @type == :error
        puts @message.colorize(:red)
      else
        puts @message.colorize(:green)
      end
    end
  end
end
