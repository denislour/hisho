require "spec"
require "../src/hisho"
require "./mock_chat_client"

describe Hisho::CLI do
  it "should return true when given the quit command" do
    cli = Hisho::CLI.new
    input = IO::Memory.new("/quit\n")
    output = IO::Memory.new

    result = cli.run(input: input, output: output)
    result.should be_true
    output.to_s.should contain("Goodbye!")
  end

  it "should display help message when given the help command" do
    cli = Hisho::CLI.new
    input = IO::Memory.new("/help\n/quit\n")
    output = IO::Memory.new

    cli.run(input: input, output: output)
    output_string = output.to_s
    output_string.should contain("Available commands:")
    output_string.should contain("/add, a: Add files or folders to context")
    output_string.should contain("/clear: Clear chat context and added files")
    output_string.should contain("/show_context: Show current conversation and added files")
    output_string.should contain("/help, h: Show this help message")
    output_string.should contain("/quit: Exit the program")
  end

  it "should display greeting message at the start" do
    cli = Hisho::CLI.new
    input = IO::Memory.new("/quit\n")
    output = IO::Memory.new

    cli.run(input: input, output: output)
    output_string = output.to_s
    output_string.should contain("Welcome to Hisho!")
    output_string.should contain("I'm here to assist you with your tasks and answer your questions.")
    output_string.should contain("Feel free to start chatting or use one of the available commands.")
    output_string.should contain("Type '/help' or '/h' to see the list of commands.")
  end
end

describe Hisho::Commands do
  describe "#chat" do
    it "updates conversation and returns AI response" do
      mock_response = "Response from AI"
      mock_client = MockChatClient.new(mock_response)
      Hisho::Commands.set_chat_client(mock_client)

      conversation = [] of String
      last_ai_response = ""
      output = IO::Memory.new

      new_conversation, new_ai_response = Hisho::Commands.chat("Hello", conversation, last_ai_response, output)

      new_conversation.size.should eq(2)
      new_conversation[0].should eq("Hello")
      new_conversation[1].should eq(mock_response)
      new_ai_response.should eq(mock_response)
      output.to_s.should contain("Me: Hello")
      output.to_s.should contain("Hisho:")
      output.to_s.should contain(mock_response)
    end
  end

  describe "#add" do
    it "adds file to context" do
      added_files = {} of String => String
      output = IO::Memory.new
      File.write("test_file.txt", "Test content")

      Hisho::Commands.add(["test_file.txt"], added_files, output)

      added_files.size.should eq(1)
      added_files["test_file.txt"].should eq("Test content")
      output.to_s.should contain("Added test_file.txt to the chat context.")

      File.delete("test_file.txt")
    end

    it "skips excluded directories" do
      added_files = {} of String => String
      output = IO::Memory.new
      Dir.mkdir("__pycache__")
      File.write("__pycache__/test_file.txt", "Test content")

      Hisho::Commands.add(["__pycache__"], added_files, output)

      added_files.size.should eq(0)
      output.to_s.should_not contain("Added __pycache__/test_file.txt to the chat context.")

      File.delete("__pycache__/test_file.txt")
      Dir.delete("__pycache__")
    end
  end

  describe "#clear" do
    it "clears conversation, added_files, and last_ai_response" do
      conversation = ["Hello", "Hi there"]
      added_files = {"test.txt" => "Test content"}
      last_ai_response = "Last response"
      output = IO::Memory.new

      cleared_conversation, cleared_added_files, cleared_last_ai_response = Hisho::Commands.clear(conversation, added_files, last_ai_response, output)

      cleared_conversation.should be_empty
      cleared_added_files.should be_empty
      cleared_last_ai_response.should eq("")
      output.to_s.should contain("Chat context and added files have been cleared.")
    end
  end

  describe "#show_context" do
    it "displays conversation and added_files" do
      conversation = ["Hello", "Hi there"]
      added_files = {"test.txt" => "This is a test file content that is longer than 100 characters to ensure we see the preview with ellipsis at the end of the content."}
      output = IO::Memory.new

      Hisho::Commands.show_context(conversation, added_files, output)

      output_string = output.to_s
      output_string.should contain("Current conversation context:")
      output_string.should contain("Me: Hello")
      output_string.should contain("Hisho: Hi there")
      output_string.should contain("Added files:")
      output_string.should contain("File: test.txt")
      output_string.should contain("Content preview: This is a test file content that is longer than 100 characters to ensure we see the preview with elli...")
    end
  end
end
