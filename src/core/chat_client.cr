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
      response = make_api_request(user_message)
      handle_response(response)
    rescue ex : Exception
      handle_error(ex)
    end

    private def make_api_request(user_message : String) : HTTP::Client::Response
      headers = HTTP::Headers{
        "Content-Type"  => "application/json",
        "Authorization" => "Bearer #{@api_key}"
      }

      body = {
        "model"    => @model,
        "messages" => [{"role" => "user", "content" => user_message}]
      }.to_json

      HTTP::Client.post(API_ENDPOINT, headers: headers, body: body)
    end

    private def handle_response(response : HTTP::Client::Response) : String?
      if response.success?
        JSON.parse(response.body)["choices"][0]["message"]["content"].as_s
      else
        raise "Error communicating with OpenRouter: #{response.status_code}"
      end
    end

    private def handle_error(ex : Exception) : String?
      puts "An error occurred: #{ex.message}".colorize(:red)
      nil
    end
  end
end
