require "spec_helper"

describe Share::Document do
  describe "initialisation" do
    let!(:doc) { Share::Document.new("foo") }
    it "should store the ID" do
      doc.id.should == "foo"
    end
  end
end
