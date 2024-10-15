module Hisho
  class ShowContextCommand < Command
    def initialize
      super(:info, "")
    end

    def execute(conversation : Conversation, chat_client : ChatClient, file : File) : Command
      result = "Current conversation context:\n"
      result += conversation.to_s
      result += "\nAdded files:\n"
      file.get_added_files.each do |file_path, content|
        result += "File: #{file_path}\n"
        result += "Content preview: #{content[0..100]}...\n" if content.size > 100
      end
      @message = result
      self
    end

    def display
      puts @message.colorize(:cyan)
    end
  end
end
