require "http/client"
require "json"

module Hisho
  abstract class ChatClient
    abstract def send_message_to_ai(user_message : String) : String?
  end

  class DefaultChatClient < ChatClient
    def initialize(@api_key : String, @model : String)
    end

    def send_message_to_ai(user_message : String) : String?
      headers = HTTP::Headers{
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@api_key}"
      }

      body = {
        "model" => @model,
        "messages" => [{"role" => "user", "content" => user_message}]
      }.to_json

      response = HTTP::Client.post("https://openrouter.ai/api/v1/chat/completions", headers: headers, body: body)

      if response.success?
        result = JSON.parse(response.body)
        return result["choices"][0]["message"]["content"].as_s
      else
        puts "Error while communicating with OpenRouter: #{response.status_code}".colorize(:red)
        return nil
      end
    rescue ex
      puts "An error occurred: #{ex.message}".colorize(:red)
      nil
    end
  end
end
