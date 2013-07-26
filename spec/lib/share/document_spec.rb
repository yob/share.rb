require "spec_helper"

describe Share::Document do
  describe "initialisation" do
    let!(:doc) { Share::Document.new("foo") }

    it "should store the ID" do
      doc.id.should == "foo"
    end

    it "should return an emtpty value" do
      doc.value.should == ""
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

  describe "#apply_op" do

    context "with a new document" do
      let!(:doc) { Share::Document.new("foo") }

      before do
        doc.apply_op(0, {'i' =>'foo', 'p' => 0})
        doc.apply_op(1, {'i' =>' bar', 'p' => 3})
      end

      it "should increment the version" do
        doc.version.should == 2
      end
    end

    context "with an out-of-order version" do
      let!(:doc) { Share::Document.new("foo") }

      it "should raise an exception" do
        lambda {
          doc.apply_op(1, {'i' =>' bar', 'p' => 3})
        }.should raise_error(Share::StaleVersionError)
      end
    end

  end
end
