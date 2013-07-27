require "spec_helper"

describe Share::Document do
  describe "initialisation" do
    let!(:doc) { Share::Document.new("foo") }

    it "should store the ID" do
      doc.id.should == "foo"
    end

    it "should return an empty value" do
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
    let!(:doc) { Share::Document.new("foo") }

    context "with two in-order insert ops" do
      before do
        doc.apply_op(0, {'i' =>'foo', 'p' => 0})
        doc.apply_op(1, {'i' =>' bar', 'p' => 3})
      end

      it "should increment the version" do
        doc.version.should == 2
      end

      it "should update the value" do
        doc.value.should == "foo bar"
      end
    end

    context "with an in-order insert and delete op" do
      before do
        doc.apply_op(0, {'i' =>'foo', 'p' => 0})
        doc.apply_op(1, {'d' =>'o', 'p' => 2})
      end

      it "should increment the version" do
        doc.version.should == 2
      end

      it "should update the value" do
        doc.value.should == "fo"
      end
    end

    context "with a 2 inserts on the same version that don't conflict" do
      before do
        doc.apply_op(0, {'i' =>'bacon', 'p' => 0})
        doc.apply_op(1, {'i' =>'chunky ', 'p' => 0})
        doc.apply_op(1, {'i' =>'!', 'p' => 5})
      end

      it "should increment the version" do
        doc.version.should == 3
      end

      it "should update the value" do
        doc.value.should == "chunky bacon!"
      end
    end

    context "with an out-of-order version" do

      it "should raise an exception" do
        lambda {
          doc.apply_op(1, {'i' =>' bar', 'p' => 3})
        }.should raise_error(Share::UnexpectedVersionError)
      end
    end

  end
end
