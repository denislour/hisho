module Hisho
  class ShowContextCommand < Command
    def initialize
      super(:info, "")
    end

    def execute(conversation_manager : ConversationManager, chat_client : ChatClient) : Command
      context = conversation_manager.get_context
      result = "Current conversation context:\n"
      context[:conversation].each do |message|
        result += "#{message}\n"
      end
      result += "\nAdded files:\n"
      context[:added_files].each do |file_path, content|
        result += "File: #{file_path}\n"
        result += "Content preview: #{content[0..100]}...\n" if content.size > 100
      end
      @message = result
      self
    end
  end
end
