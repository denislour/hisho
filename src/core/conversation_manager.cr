module Hisho
  class ConversationManager
    def initialize
      @conversation = [] of String
      @added_files = {} of String => String
    end

    def add_user_message(message : String)
      @conversation << "User: #{message}"
    end

    def add_ai_response(response : String)
      @conversation << "AI: #{response}"
    end

    def clear
      @conversation.clear
      @added_files.clear
    end

    def add_file(path : String, content : String)
      @added_files[path] = content
    end

    def get_context
      {conversation: @conversation, added_files: @added_files}
    end
  end
end
