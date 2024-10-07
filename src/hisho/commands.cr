require "readline"
require "colorize"
require "http/client"
require "json"
require "file_utils"

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
      puts "Me: #{input}".colorize(:green)
      ai_response = @@chat_client.chat_with_ai(input)
      if ai_response
        puts "Hisho:".colorize(:blue)
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

    def add(paths : Array(String), added_files : Hash(String, String))
      paths.each do |path|
        if File.file?(path)
          add_file_to_context(path, added_files)
        elsif Dir.exists?(path)
          Dir.glob("#{path}/**/*").each do |file_path|
            next if File.directory?(file_path)
            next if file_path.includes?("__pycache__") || file_path.includes?(".git") || file_path.includes?("node_modules")
            add_file_to_context(file_path, added_files)
          end
        else
          puts "Error: #{path} is not a file or directory.".colorize(:red)
        end
      end

      total_size = added_files.values.sum(&.bytesize)
      if total_size > 100_000 # Warning if total size exceeds ~100KB
        puts "Warning: The total size of added files is large and may affect performance.".colorize(:red)
      end
    end

    private def add_file_to_context(file_path : String, added_files : Hash(String, String))
      context = File.read(file_path)
      added_files[file_path] = context
      puts "Added #{file_path} to the chat context.".colorize(:green)
    rescue ex
      puts "Error reading file #{file_path}: #{ex.message}".colorize(:red)
    end

    def clear(conversation : Array(String), added_files : Hash(String, String), last_ai_response : String)
      conversation.clear
      added_files.clear
      last_ai_response = ""
      {conversation, added_files, last_ai_response}  # Trả về cả ba giá trị đã được xóa
    end

    def show_context(conversation : Array(String), added_files : Hash(String, String), output : IO = STDOUT)
      output.puts "Current conversation context:".colorize(:yellow)
      conversation.each_with_index do |message, index|
        role = index.even? ? "User" : "AI"
        output.puts "#{role}: #{message}"
      end

      output.puts "\nAdded files:".colorize(:yellow)
      added_files.each do |file_path, context|
        output.puts "File: #{file_path}".colorize(:blue)
        if context.size > 100
          output.puts "Content preview: #{context[0..100]}..."
        else
          output.puts "Content preview: #{context}"
        end
      end
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
