require "readline"
require "colorize"
require "http/client"
require "json"

module Hisho
  module Commands
    extend self

    @@api_key : String?
    @@model : String?
    @@chat_client : ChatClient = DefaultChatClient.new

    def setup(api_key : String?, model : String?)
      @@api_key = api_key
      @@model = model
    end

    def set_chat_client(client : ChatClient)
      @@chat_client = client
    end

    def chat(input, conversation, last_ai_response)
      puts "User: #{input}".colorize(:green)
      ai_response = @@chat_client.chat_with_ai(input)
      if ai_response
        puts
        puts "hisho:".colorize(:blue)
        puts ai_response
        last_ai_response = ai_response
        conversation << input
        conversation << ai_response
      end
      {conversation, last_ai_response}
    end

    def chat_with_ai(user_message : String) : String?
      return nil if @@api_key.nil?

      headers = HTTP::Headers{
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@@api_key}"
      }

      body = {
        "model" => @@model,
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

  abstract class ChatClient
    abstract def chat_with_ai(user_message : String) : String?
  end

  class DefaultChatClient < ChatClient
    def chat_with_ai(user_message : String) : String?
      Commands.chat_with_ai(user_message)
    end
  end
end
