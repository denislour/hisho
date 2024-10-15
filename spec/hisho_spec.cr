require "spec"
require "../src/hisho"
require "./mock_chat_client"

describe Hisho::CLI do
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

describe Hisho::Command do
  conversation = Hisho::Conversation.new
  chat_client = MockChatClient.new("Test response")
  file = Hisho::File.new

  it "should return quit result when given quit command" do
    command = Hisho::CommandBuilder.build("/quit")
    result = command.execute(conversation, chat_client, file)
    result.type.should eq(:quit)
    result.message.should eq("Goodbye!")
  end

  it "should display help message when given the help command" do
    command = Hisho::CommandBuilder.build("/help")
    result = command.execute(conversation, chat_client, file)
    result.type.should eq(:info)
    result.message.should contain("Available commands:")
    result.message.should contain("/add, /a [path]: Add files or folders to context")
    result.message.should contain("/clear: Clear chat context and added files")
    result.message.should contain("/show_context: Show current conversation and added files")
    result.message.should contain("/help, /h: Show this help message")
    result.message.should contain("/quit, /q: Exit the program")
  end

  it "should return chat result when given a non-command input" do
    command = Hisho::CommandBuilder.build("Hello, AI")
    result = command.execute(conversation, chat_client, file)
    result.type.should eq(:chat)
    result.message.should eq("Test response")
  end

  it "should return info result when given clear command" do
    command = Hisho::CommandBuilder.build("/clear")
    result = command.execute(conversation, chat_client, file)
    result.type.should eq(:info)
    result.message.should contain("Chat context and added files have been cleared.")
  end

  it "should return info result when given show_context command" do
    conversation.add_user_message("Test message")
    conversation.add_ai_response("Test response")
    command = Hisho::CommandBuilder.build("/show_context")
    result = command.execute(conversation, chat_client, file)
    result.type.should eq(:info)
    result.message.should contain("Current conversation context:")
    result.message.should contain("User: Test message")
    result.message.should contain("AI: Test response")
  end
end

describe Hisho::Conversation do
  it "should add user message and AI response" do
    conversation = Hisho::Conversation.new
    conversation.add_user_message("Hello")
    conversation.add_ai_response("Hi there")

    conversation_history = conversation.get_conversation
    conversation_history.size.should eq(2)
    conversation_history[0].should eq("User: Hello")
    conversation_history[1].should eq("AI: Hi there")
  end

  it "should clear conversation" do
    conversation = Hisho::Conversation.new
    conversation.add_user_message("Hello")
    conversation.add_ai_response("Hi there")

    conversation.clear

    conversation_history = conversation.get_conversation
    conversation_history.should be_empty
  end
end

describe Hisho::File do
  it "should add file to context" do
    file = Hisho::File.new
    file.add("test.txt", "Test content")

    added_files = file.get_added_files
    added_files["test.txt"].should eq("Test content")
  end

  it "should clear added files" do
    file = Hisho::File.new
    file.add("test.txt", "Test content")

    file.clear

    added_files = file.get_added_files
    added_files.should be_empty
  end
end
