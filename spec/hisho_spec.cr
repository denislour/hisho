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
  it "should update conversation and return AI response when given a chat command" do
    mock_response = "Response from AI"
    mock_client = MockChatClient.new(mock_response)
    Hisho::Commands.set_chat_client(mock_client)

    conversation = [] of String
    last_ai_response = ""

    new_conversation, new_ai_response = Hisho::Commands.chat("Hello", conversation, last_ai_response)

    new_conversation.size.should eq(2)
    new_conversation[0].should eq("Hello")
    new_conversation[1].should eq(mock_response)
    new_ai_response.should eq(mock_response)
  end

  describe "#add" do
    it "adds file to context" do
      added_files = {} of String => String
      File.write("test_file.txt", "Test content")

      Hisho::Commands.add(["test_file.txt"], added_files)

      added_files.size.should eq(1)
      added_files["test_file.txt"].should eq("Test content")

      File.delete("test_file.txt")
    end

    it "skips excluded directories" do
      added_files = {} of String => String
      Dir.mkdir("__pycache__")
      File.write("__pycache__/test_file.txt", "Test content")

      Hisho::Commands.add(["__pycache__"], added_files)

      added_files.size.should eq(0)

      File.delete("__pycache__/test_file.txt")
      Dir.delete("__pycache__")
    end
  end

  describe "#clear" do
    it "clears conversation and added_files" do
      conversation = ["Hello", "Hi there"]
      added_files = {"test.txt" => "Test content"}
      last_ai_response = "Last response"

      cleared_conversation, cleared_added_files, cleared_last_ai_response = Hisho::Commands.clear(conversation, added_files, last_ai_response)

      cleared_conversation.should be_empty
      cleared_added_files.should be_empty
      cleared_last_ai_response.should be_empty
    end
  end

  describe "#show_context" do
    it "displays conversation and added_files" do
      conversation = ["User: Hello", "AI: Hi there"]
      added_files = {"test.txt" => "This is a test file content that is longer than 30 characters to ensure we see the preview"}

      output = IO::Memory.new
      Hisho::Commands.show_context(conversation, added_files, output)

      output_string = output.to_s

      puts output_string

      output_string.should contain("Current conversation context:")
      output_string.should contain("User: Hello")
      output_string.should contain("AI: Hi there")
      output_string.should contain("Added files:")
      output_string.should contain("File: test.txt")
      output_string.should contain("Content preview: This is a test file content that is longer than 30 characters to ensure we see the preview")
    end
  end
end