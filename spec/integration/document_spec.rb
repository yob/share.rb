require "spec_helper"

describe Share::Document do

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
        doc.snapshot.should == "foo bar"
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
        doc.snapshot.should == "fo"
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

      it "should return the latest snapshot" do
        doc.snapshot.should == "chunky bacon!"
      end

      it "should return the snapshot for version 2" do
        doc.snapshot(2).should == "chunky bacon"
      end

      it "should return the snapshot for version 1" do
        doc.snapshot(1).should == "bacon"
      end

      it "should return the snapshot for version 0" do
        doc.snapshot(0).should == ""
      end
    end

    context "with a 2 operations on the same version" do
      before do
        doc.apply_op(0, {'i' =>'bacon', 'p' => 0})
        doc.apply_op(1, {'i' =>'chunky ', 'p' => 0})
        doc.apply_op(1, {'d' =>'con', 'p' => 2})
      end

      it "should increment the version" do
        doc.version.should == 3
      end

      it "should update the value" do
        doc.snapshot.should == "chunky ba"
      end
    end

    context "with a 2 inserts on the same version that conflict" do
      before do
        doc.apply_op(0, {'i' =>'bacon', 'p' => 0})
        doc.apply_op(1, {'i' =>'chunky ', 'p' => 0})
        doc.apply_op(1, {'i' =>'cooked ', 'p' => 0})
      end

      it "should increment the version" do
        doc.version.should == 3
      end

      it "should update the value" do
        doc.snapshot.should == "cooked chunky bacon"
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

