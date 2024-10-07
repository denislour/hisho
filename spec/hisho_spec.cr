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
      cleared_last_ai_response.should be_empty
      output.to_s.should contain("Chat context and added files have been cleared.")
    end
  end

  describe "#show_context" do
    it "displays conversation and added_files" do
      conversation = ["User: Hello", "AI: Hi there"]
      added_files = {"test.txt" => "This is a test file content."}
      output = IO::Memory.new

      Hisho::Commands.show_context(conversation, added_files, output)

      output_string = output.to_s
      output_string.should contain("Current conversation context:")
      output_string.should contain("User: Hello")
      output_string.should contain("AI: Hi there")
      output_string.should contain("Added files:")
      output_string.should contain("File: test.txt")
    end
  end
end
