require 'spec_helper'

describe Share::Message do

  it "disallows creating with an op" do
    message = JSON.dump op: true, create: true
    lambda {
      Share::Message.new(message)
    }.should raise_error(Share::ProtocolError)
  end

  it "disallows requesting a snapshot with an op" do
    message = JSON.dump op: true, snapshot: nil
    lambda {
      Share::Message.new(message)
    }.should raise_error(Share::ProtocolError)
  end

  it "disallows opening with an op" do
    message = JSON.dump op: true, open: true
    lambda {
      Share::Message.new(message)
    }.should raise_error(Share::ProtocolError)
  end

  it "disallows close with create" do
    message = JSON.dump open: false, create: true
    lambda {
      Share::Message.new(message)
    }.should raise_error(Share::ProtocolError)
  end

  it "disallows close with snapshot request" do
    message = JSON.dump open: false, snapshot: nil
    lambda {
      Share::Message.new(message)
    }.should raise_error(Share::ProtocolError)
  end

end
