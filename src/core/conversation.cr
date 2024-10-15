module Hisho
  class Conversation
    def initialize
      @conversation = [] of String
    end

    def add_user_message(message : String)
      @conversation << "User: #{message}"
    end

    def add_ai_response(response : String)
      @conversation << "AI: #{response}"
    end

    def clear
      @conversation.clear
    end

    def get_conversation
      @conversation
    end

    def to_s : String
      @conversation.join("\n")
    end
  end
end
