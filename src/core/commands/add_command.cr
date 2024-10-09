module Hisho
  class AddCommand < Command
    def initialize(@paths : Array(String))
      super(:info, "")
    end

    def execute(conversation_manager : ConversationManager, chat_client : ChatClient) : Command
      added_files = [] of String
      @paths.each do |path|
        if File.file?(path)
          add_file_to_context(path, conversation_manager)
          added_files << path
        elsif Dir.exists?(path)
          add_directory_to_context(path, conversation_manager)
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

    private def add_file_to_context(file_path : String, conversation_manager : ConversationManager)
      content = File.read(file_path)
      conversation_manager.add_file(file_path, content)
    end

    private def add_directory_to_context(dir_path : String, conversation_manager : ConversationManager)
      Dir.glob("#{dir_path}/**/*").each do |file_path|
        next if File.directory?(file_path)
        next if file_path.includes?("__pycache__") || file_path.includes?(".git") || file_path.includes?("node_modules")
        add_file_to_context(file_path, conversation_manager)
      end
    end
  end
end
