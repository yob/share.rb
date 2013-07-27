require 'spec_helper'

describe Share::Types::Text do
  let!(:text) { Share::Types::Text.new }

  context "transform" do
    it "is sane" do
      text.transform([], [], 'left').should == []
      text.transform([], [], 'right').should == []

      text.transform([{'i' =>'y', 'p' =>100}, {'i' =>'x', 'p' =>0}], [], 'left').should == [{'i' =>'y', 'p' =>100}, {'i' =>'x', 'p' =>0}]
      text.transform([], [{'i' =>'y', 'p' =>100}, {'i' =>'x', 'p' =>0}], 'right').should == []
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
