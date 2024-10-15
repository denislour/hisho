require "http/client"
require "json"

module Hisho
  abstract class ChatClient
    abstract def send_message_to_ai(user_message : String) : String?
  end

  class DefaultChatClient < ChatClient
    API_ENDPOINT = "https://openrouter.ai/api/v1/chat/completions"

    def initialize(@api_key : String, @model : String)
    end

    def send_message_to_ai(user_message : String) : String?
      make_api_request(user_message).try { |response| handle_response(response) }
    rescue ex
      handle_error(ex)
    end

    private def make_api_request(user_message : String) : HTTP::Client::Response
      HTTP::Client.post(
        API_ENDPOINT,
        headers: HTTP::Headers{"Content-Type" => "application/json", "Authorization" => "Bearer #{@api_key}"},
        body: {"model" => @model, "messages" => [{"role" => "user", "content" => user_message}]}.to_json
      )
    end

    private def handle_response(response : HTTP::Client::Response) : String?
      response.success? ? JSON.parse(response.body)["choices"][0]["message"]["content"].as_s : raise "Error: #{response.status_code}"
    end

    private def handle_error(ex : Exception) : String?
      puts "Error: #{ex.message}".colorize(:red)
      nil
    end
  end
end
