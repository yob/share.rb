require "spec_helper"

# unit-ish tests of the Document class. See also integration/document_spec.rb
# for tests that work documents with collaborators

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
