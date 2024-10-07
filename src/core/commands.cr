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

    def chat(input, conversation, last_ai_response, output : IO = STDOUT)
      output.puts "Me: #{input}".colorize(:green)
      ai_response = @@chat_client.chat_with_ai(input)
      if ai_response
        output.puts "Hisho:".colorize(:blue)
        output.puts ai_response
        last_ai_response = ai_response
        conversation << input << ai_response
      end
      {conversation, last_ai_response}
    end

    def add(paths : Array(String), added_files : Hash(String, String), output : IO = STDOUT)
      paths.each do |path|
        if File.file?(path)
          add_file_to_context(path, added_files, output)
        elsif Dir.exists?(path)
          add_directory_to_context(path, added_files, output)
        else
          output.puts "Error: #{path} is not a file or directory.".colorize(:red)
        end
      end

      warn_if_large_context(added_files, output)
    end

    def clear(conversation, added_files, last_ai_response, output : IO = STDOUT)
      conversation.clear
      added_files.clear
      last_ai_response = ""
      output.puts "Chat context and added files have been cleared.".colorize(:green)
      {conversation, added_files, last_ai_response}
    end

    def show_context(conversation : Array(String), added_files : Hash(String, String), output : IO = STDOUT)
      output.puts "Current conversation context:".colorize(:yellow)
      conversation.each_with_index do |message, index|
        role = index.even? ? "Me" : "Hisho"
        output.puts "#{role}: #{message}"
      end

      output.puts "\nAdded files:".colorize(:yellow)
      added_files.each do |file_path, context|
        output.puts "File: #{file_path}".colorize(:blue)
        output.puts "Content preview: #{context[0..100]}..." if context.size > 100
      end
    end

    private def add_file_to_context(file_path : String, added_files : Hash(String, String), output : IO)
      context = File.read(file_path)
      added_files[file_path] = context
      output.puts "Added #{file_path} to the chat context.".colorize(:green)
    rescue ex
      output.puts "Error reading file #{file_path}: #{ex.message}".colorize(:red)
    end

    private def add_directory_to_context(dir_path : String, added_files : Hash(String, String), output : IO)
      Dir.glob("#{dir_path}/**/*").each do |file_path|
        next if File.directory?(file_path)
        next if file_path.includes?("__pycache__") || file_path.includes?(".git") || file_path.includes?("node_modules")
        add_file_to_context(file_path, added_files, output)
      end
    end

    private def warn_if_large_context(added_files : Hash(String, String), output : IO)
      total_size = added_files.values.sum(&.bytesize)
      if total_size > 100_000
        output.puts "Warning: The total size of added files is large and may affect performance.".colorize(:red)
      end
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
end
