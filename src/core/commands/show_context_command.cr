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
      message = String.build do |str|
        str << "Current conversation context:\n"
        conversation.get_conversation.each { |msg| str << "#{msg}\n" }
        str << "\nAdded files:\n"
        file.get_added_files.each do |file_path, content|
          str << "File: #{file_path}\n"
          str << "Content preview: #{content[0..100]}...\n" if content.size > 100
        end
      end
      message
    end
  end
end
