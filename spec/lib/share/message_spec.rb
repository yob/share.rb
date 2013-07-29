require 'spec_helper'

describe Share::Message do

  describe "invalid messages" do
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

  describe "#document" do
    let!(:data) { JSON.dump(doc: "test") }
    let!(:msg) { Share::Message.new(data) }

    it "should return the doc ID" do
      msg.document.should == "test"
    end
  end

  describe "#type" do
    let!(:data) { JSON.dump(type: "text") }
    let!(:msg) { Share::Message.new(data) }

    it "should return the doc type" do
      msg.type.should == "text"
    end
  end

  describe "#create?" do
    context "with a create message" do
      let!(:data) { JSON.dump(doc: "test", type: "text", create: true) }
      let!(:msg) { Share::Message.new(data) }

      it "should return true" do
        msg.create?.should be_true
      end
    end
    context "with a non-create message" do
      let!(:data) { JSON.dump(doc: "test") }
      let!(:msg) { Share::Message.new(data) }

      it "should return false" do
        msg.create?.should be_false
      end
    end
  end

  describe "#snapshot?" do
    context "with a message requesting a snapshot" do
      let!(:data) { JSON.dump(doc: "test", snapshot: nil) }
      let!(:msg) { Share::Message.new(data) }

      it "should return true" do
        msg.snapshot?.should be_true
      end
    end
    context "with a message not requesting a snapshot" do
      let!(:data) { JSON.dump(doc: "test") }
      let!(:msg) { Share::Message.new(data) }

      it "should return false" do
        msg.snapshot?.should be_false
      end
    end
  end

  describe "#open?" do
    context "with an open message" do
      let!(:data) { JSON.dump(doc: "test", open: true) }
      let!(:msg) { Share::Message.new(data) }

      it "should return true" do
        msg.open?.should be_true
      end
    end
    context "with a close message" do
      let!(:data) { JSON.dump(doc: "test", open: false) }
      let!(:msg) { Share::Message.new(data) }

      it "should return false" do
        msg.open?.should be_false
      end
    end
    context "with neither and open or a close message" do
      let!(:data) { JSON.dump(doc: "test") }
      let!(:msg) { Share::Message.new(data) }

      it "should return false" do
        msg.open?.should be_false
      end
    end
  end

  describe "#close?" do
    context "with an open message" do
      let!(:data) { JSON.dump(doc: "test", open: true) }
      let!(:msg) { Share::Message.new(data) }

      it "should return false" do
        msg.close?.should be_false
      end
    end
    context "with a close message" do
      let!(:data) { JSON.dump(doc: "test", open: false) }
      let!(:msg) { Share::Message.new(data) }

      it "should return true" do
        msg.close?.should be_true
      end
    end
    context "with neither and open or a close message" do
      let!(:data) { JSON.dump(doc: "test") }
      let!(:msg) { Share::Message.new(data) }

      it "should return false" do
        msg.close?.should be_false
      end
    end
  end
  describe "#auth?" do
    context "with an auth message" do
      let!(:data) { JSON.dump(auth: "12345") }
      let!(:msg) { Share::Message.new(data) }

      it "should return true" do
        msg.auth?.should be_true
      end
    end
    context "with a non-auth message" do
      let!(:data) { JSON.dump(doc: "test") }
      let!(:msg) { Share::Message.new(data) }

      it "should return false" do
        msg.auth?.should be_false
      end
    end
  end
  describe "#auth" do
    context "with an auth message" do
      let!(:data) { JSON.dump(auth: "12345") }
      let!(:msg) { Share::Message.new(data) }

      it "should return the auth value" do
        msg.auth.should == "12345"
      end
    end
    context "with a non-auth message" do
      let!(:data) { JSON.dump(doc: "test") }
      let!(:msg) { Share::Message.new(data) }

      it "should return nil" do
        msg.auth.should be_nil
      end
    end
  end

  describe "#operation?" do
    context "with an operation message" do
      let!(:data) { JSON.dump(doc: "test", op: {i: 'foo', p: 0}) }
      let!(:msg) { Share::Message.new(data) }

      it "should return true" do
        msg.operation?.should be_true
      end
    end
    context "with a non-operation message" do
      let!(:data) { JSON.dump(doc: "test") }
      let!(:msg) { Share::Message.new(data) }

      it "should return false" do
        msg.operation?.should be_false
      end
    end
  end
  describe "#operation" do
    context "with an operation message" do
      let!(:data) { JSON.dump(doc: "test", op: {i: 'foo', p: 0}) }
      let!(:msg) { Share::Message.new(data) }

      it "should return the operation" do
        msg.operation.should == {"i" => 'foo', "p" => 0}
      end
    end
  end
  describe "#version" do
    context "with a versioned message" do
      let!(:data) { JSON.dump(doc: "test", v: 10, op: {i: 'foo', p: 0}) }
      let!(:msg) { Share::Message.new(data) }

      it "should return the version" do
        msg.version.should == 10
      end
    end
  end

end
