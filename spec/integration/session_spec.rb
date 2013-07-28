require 'spec_helper'

describe Share::Session do
  let(:repo) { Share::Repo.new }
  let(:session) { Share::Session.new(repo) }
  let(:message) do
    require 'json'
    Share::Message.new ::JSON.dump(message_data)
  end

  describe "respond_to(message)" do
    let(:response) { session.handle_message message }

    describe "close message" do
      let(:message_data) do
        { doc: "test", open: false}
      end

      it "closes" do
        response[:open].should == false
      end
    end

    describe "creating a document that already exists" do
      let(:adapter) { ExistingAdapter }
      let(:message_data) do
        { doc: "test", create: true, type: "json" }
      end

      it "responds with create: false" do
        response[:create].should == false
      end
    end

    describe "creating a new document" do
      let(:message_data) do
        { doc: "test", create: true, type: "json" }
      end

      it "responds with create: true" do
        response[:create].should == true
      end

      it "responds with document metadata" do
        response[:meta].should == :metadata
      end
    end

    describe "document that doesn't exist" do
      let(:message_data) do
        { doc: "test", type: "json" }
      end

      it "responds with an error" do
        response.has_key?(:error).should == true
        response[:error].should match "Document does not exist"
      end
    end

    describe "document type doesn't match type in repo" do
      let(:message_data) do
        { doc: "test", type: "text"}
      end

      it "responds with an error" do
        response.has_key?(:error).should == true
        response[:error].should match "Type mismatch"
      end
    end

    describe "open request with an error" do
      let(:message_data) do
        { doc: "test", type: "text", open: true}
      end

      it "cancels opening the document" do
        response[:open].should == false
      end
    end

    describe "snapshot request" do
      let(:adapter) { ExistingAdapter }
      let(:message_data) do
        { doc: "test", type: "json", snapshot: nil}
      end

      it "responds with the snapshot" do
        response[:snapshot].should == :snapshot
      end
    end

    describe "open request" do
      let(:adapter) { ExistingAdapter }
      let(:message_data) do
        { doc: "test", open: true}
      end

      it "responds in the affirmative" do
        response[:open].should == true
      end

      it "responds with the opened version" do
        response[:v].should == :version
      end

      it "subscribes to the document" do
        response
        #app.subscriptions["test"].include?(session.id).should == true
      end
    end
  end
end
