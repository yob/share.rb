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
      text.transform_x([{'i' =>'x', 'p' =>9}], [{'i' =>'a', 'p' =>1}]).should == [[{'i' =>'x', 'p' =>10}], [{'i' =>'a', 'p' =>1}]]
      text.transform_x([{'i' =>'x', 'p' =>10}], [{'i' =>'a', 'p' =>10}]).should == [[{'i' =>'x', 'p' =>10}], [{'i' =>'a', 'p' =>11}]]

      text.transform_x([{'i' =>'x', 'p' =>11}], [{'d' =>'a', 'p' =>9}]).should == [[{'i' =>'x', 'p' =>10}], [{'d' =>'a', 'p' =>9}]]
      text.transform_x([{'i' =>'x', 'p' =>11}], [{'d' =>'a', 'p' =>10}]).should == [[{'i' =>'x', 'p' =>10}], [{'d' =>'a', 'p' =>10}]]
      text.transform_x([{'i' =>'x', 'p' =>11}], [{'d' =>'a', 'p' =>11}]).should == [[{'i' =>'x', 'p' =>11}], [{'d' =>'a', 'p' =>12}]]

      text.transform([{'i' =>'x', 'p' =>10}], [{'d' =>'a', 'p' =>11}], 'left').should == [{'i' =>'x', 'p' =>10}]
      text.transform([{'i' =>'x', 'p' =>10}], [{'d' =>'a', 'p' =>10}], 'left').should == [{'i' =>'x', 'p' =>10}]
      text.transform([{'i' =>'x', 'p' =>10}], [{'d' =>'a', 'p' =>10}], 'right').should == [{'i' =>'x', 'p' =>10}]
    end

    it "deletes" do
      text.transform_x([{'d' =>'abc', 'p' =>10}], [{'d' =>'xy', 'p' =>4}]).should == [[{'d' =>'abc', 'p' =>8}], [{'d' =>'xy', 'p' =>4}]]
      text.transform_x([{'d' =>'abc', 'p' =>10}], [{'d' =>'b', 'p' =>11}]).should == [[{'d' =>'ac', 'p' =>10}], []]
      text.transform_x([{'d' =>'b', 'p' =>11}], [{'d' =>'abc', 'p' =>10}]).should == [[], [{'d' =>'ac', 'p' =>10}]]
      text.transform_x([{'d' =>'abc', 'p' =>10}], [{'d' =>'bc', 'p' =>11}]).should == [[{'d' =>'a', 'p' =>10}], []]
      text.transform_x([{'d' =>'abc', 'p' =>10}], [{'d' =>'ab', 'p' =>10}]).should == [[{'d' =>'c', 'p' =>10}], []]
      text.transform_x([{'d' =>'abc', 'p' =>10}], [{'d' =>'bcd', 'p' =>11}]).should == [[{'d' =>'a', 'p' =>10}], [{'d' =>'d', 'p' =>10}]]
      text.transform_x([{'d' =>'bcd', 'p' =>11}], [{'d' =>'abc', 'p' =>10}]).should == [[{'d' =>'d', 'p' =>10}], [{'d' =>'a', 'p' =>10}]]
      text.transform_x([{'d' =>'abc', 'p' =>10}], [{'d' =>'xy', 'p' =>13}]).should == [[{'d' =>'abc', 'p' =>10}], [{'d' =>'xy', 'p' =>10}]]
    end
  end

end
