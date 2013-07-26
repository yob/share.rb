require "spec_helper"

describe Share::Document do
  describe "initialisation" do
    let!(:doc) { Share::Document.new("foo") }

    it "should store the ID" do
      doc.id.should == "foo"
    end

  end

  describe "#version" do

    context "with a new document" do
      let!(:doc) { Share::Document.new("foo") }

      it "should be 0" do
        doc.version.should == 0
      end
    end

  end
end
