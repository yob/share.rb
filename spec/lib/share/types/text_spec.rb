require 'spec_helper'

describe Share::Types::Text do
  let!(:text) { Share::Types::Text.new }

  describe "#apply" do
    context "1 insert" do
      it "should return the correct snapshot" do
        text.apply("", [{'i' => 'foo', 'p' => 0}]).should == "foo"
      end
    end
    context "2 non-conflicting inserts" do
      it "should return the correct snapshot" do
        text.apply("", [{'i' => 'foo', 'p' => 0}, {'i' => ' bar', 'p' => 3}]).should == "foo bar"
      end
    end
    context "1 delete" do
      it "should return the correct snapshot" do
        text.apply("foo bar", [{'d' => ' bar', 'p' => 3}]).should == "foo"
      end
    end
    context "2 non-conflicting deletes" do
      it "should return the correct snapshot" do
        text.apply("foo bar", [{'d' => 'r', 'p' => 6}, {'d' => 'o', 'p' => 2}]).should == "fo ba"
      end
    end
    context "non-conflicting insert and delete" do
      it "should return the correct snapshot" do
        text.apply("", [{'i' => 'foo bar', 'p' => 0}, {'d' => ' bar', 'p' => 3}]).should == "foo"
      end
    end
    context "non-conflicting delete and insert" do
      it "should return the correct snapshot" do
        text.apply("foo bar", [{'d' => ' bar', 'p' => 3},{'i' => ' baz', 'p' => 3}]).should == "foo baz"
      end
    end
    context "invalid delete" do
      it "should raise an exception" do
        lambda {
          text.apply("foo bar", [{'d' => ' baz', 'p' => 3}])
        }.should raise_error(Share::Types::Text::DeletedStringDoesNotMatch)
      end
    end
  end

  describe "#transform" do
    context "left tranform with no ops" do
      it "should return an empty array" do
        text.transform([], [], 'left').should == []
      end
    end

    context "right tranform with no ops" do
      it "should return an empty array" do
        text.transform([], [], 'right').should == []
      end
    end

    context "left tranform with no right ops" do
      it "should return left ops unchanched" do
        text.transform([{'i' =>'y', 'p' =>100}, {'i' =>'x', 'p' =>0}], [], 'left').should == [{'i' =>'y', 'p' =>100}, {'i' =>'x', 'p' =>0}]
      end
    end

    context "right tranform with no left ops" do
      it "should return an empty array" do
        text.transform([], [{'i' =>'y', 'p' =>100}, {'i' =>'x', 'p' =>0}], 'right').should == []
      end
    end

    it "inserts" do
      text.transform([{'i' =>'x', 'p' =>9}], [{'i' =>'a', 'p' =>1}, {'i' =>'a', 'p' =>100}], "left").should == [{'i' =>'x', 'p' =>10}]
      text.transform([{'i' =>'x', 'p' =>9},{'i' =>'y', 'p' =>10}], [{'i' =>'a', 'p' =>1}], "left").should == [{'i' =>'xy', 'p' =>10}]
      text.transform([{'i' =>'x', 'p' =>9},{'i' =>'y', 'p' =>11}], [{'i' =>'a', 'p' =>1}], "left").should == [{'i' =>'x', 'p' =>10},{'i' =>'y', 'p' =>12}]

      text.transform([{'i' =>'x', 'p' =>11}], [{'d' =>'a', 'p' =>9},{'d' =>'a', 'p' =>100}], "left").should == [{'i' =>'x', 'p' =>10}]
      text.transform([{'i' =>'x', 'p' =>11}], [{'d' =>'a', 'p' =>10},{'d' =>'a', 'p' =>100}], "left").should == [{'i' =>'x', 'p' =>10}]
      text.transform([{'i' =>'x', 'p' =>11}], [{'d' =>'a', 'p' =>11},{'d' =>'a', 'p' =>100}], "left").should == [{'i' =>'x', 'p' =>11}]

      text.transform([{'i' =>'x', 'p' =>10}], [{'d' =>'a', 'p' =>11},{'d' =>'a', 'p' =>100}], 'left').should == [{'i' =>'x', 'p' =>10}]
      text.transform([{'i' =>'x', 'p' =>10}], [{'d' =>'a', 'p' =>10},{'d' =>'a', 'p' =>100}], 'left').should == [{'i' =>'x', 'p' =>10}]
      text.transform([{'i' =>'x', 'p' =>10}], [{'d' =>'a', 'p' =>10},{'d' =>'a', 'p' =>100}], 'right').should == [{'i' =>'x', 'p' =>10}]
    end

    it "deletes" do
      text.transform([{'d' =>'abc', 'p' =>10}], [{'d' =>'xy', 'p' =>4},{'d' =>'a', 'p' =>100}], "left").should == [{'d' =>'abc', 'p' =>8}]
      text.transform([{'d' =>'abc', 'p' =>10}], [{'d' =>'b', 'p' =>11},{'d' =>'a', 'p' =>100}], "left").should == [{'d' =>'ac', 'p' =>10}]
      text.transform([{'d' =>'b', 'p' =>11}], [{'d' =>'abc', 'p' =>10},{'d' =>'a', 'p' =>100}], "left").should == []
      text.transform([{'d' =>'abc', 'p' =>10}], [{'d' =>'bc', 'p' =>11},{'d' =>'a', 'p' =>100}], "left").should == [{'d' =>'a', 'p' =>10}]
      text.transform([{'d' =>'abc', 'p' =>10}], [{'d' =>'ab', 'p' =>10},{'d' =>'a', 'p' =>100}], "left").should == [{'d' =>'c', 'p' =>10}]
      text.transform([{'d' =>'abc', 'p' =>10}], [{'d' =>'bcd', 'p' =>11},{'d' =>'a', 'p' =>100}], "left").should == [{'d' =>'a', 'p' =>10}]
      text.transform([{'d' =>'bcd', 'p' =>11}], [{'d' =>'abc', 'p' =>10},{'d' =>'a', 'p' =>100}], "left").should == [{'d' =>'d', 'p' =>10}]
      text.transform([{'d' =>'abc', 'p' =>10}], [{'d' =>'xy', 'p' =>13},{'d' =>'a', 'p' =>100}], "left").should == [{'d' =>'abc', 'p' =>10}]
    end
  end

end
