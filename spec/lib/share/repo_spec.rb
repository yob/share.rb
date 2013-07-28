require "spec_helper"

describe Share::Repo do
  describe "#get" do
    context "with an empty repo" do
      let!(:repo) { Share::Repo.new }

      it "should return nil" do
        repo.get("foo").should be_nil
      end
    end
  end

  describe "#create" do
    context "with an empty repo" do
      let!(:repo) { Share::Repo.new }

      context "creating a new document with a valid type" do
        let!(:doc) { repo.create("foo", "text") }
        it "should be a document" do
          doc.should be_a(Share::Document)
        end

        it "should have the correct ID" do
          doc.id.should == "foo"
        end
      end
      context "creating a new document with an invalid type" do
        it "should be a document" do
          lambda {
            repo.create("foo", "text2")
          }.should raise_error(Share::Repo::UnsupportedTypeError)
        end
      end
    end
  end
end
