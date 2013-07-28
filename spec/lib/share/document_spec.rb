require "spec_helper"

# unit-ish tests of the Document class. See also integration/document_spec.rb
# for tests that work documents with collaborators

describe Share::Document do
  describe "initialisation" do
    context "wit hno type" do
      let!(:doc) { Share::Document.new("foo") }

      it "should store the ID" do
        doc.id.should == "foo"
      end

      it "should use the default type" do
        doc.type.should == "text"
      end
    end
    context "with a valid type" do
      let!(:doc) { Share::Document.new("foo", "text") }

      it "should set the type" do
        doc.type.should == "text"
      end
    end
    context "with an invalid type" do
      it "should raise an exception" do
        lambda {
          Share::Document.new("foo", "text2")
        }.should raise_error(Share::UnsupportedTypeError)
      end
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
