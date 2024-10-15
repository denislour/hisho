module Hisho
  class ShowContextCommand < Command
    def initialize
      super(:info, "")
    end

    def execute(conversation : Conversation, chat_client : ChatClient, file : File) : Command
      @message = build_context_message(conversation, file)
      self
    end

    def display
      puts @message.colorize(:cyan)
    end

    private def build_context_message(conversation : Conversation, file : File) : String
      message = "Current conversation context:\n"
      conversation.get_conversation.each do |msg|
        message += "#{msg}\n"
      end
      message += "\nAdded files:\n"
      file.get_added_files.each do |file_path, content|
        message += "File: #{file_path}\n"
        message += "Content preview: #{content[0..100]}...\n" if content.size > 100
      end
      message
    end
  end
end
