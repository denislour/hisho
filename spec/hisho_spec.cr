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
    output.to_s.should contain("Bye!")
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
end