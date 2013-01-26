require 'spec_helper'

describe ParameterSet do
  let(:one) { ParameterSet.new(7,3) } # 7,3
  let(:other) { ParameterSet.new(5,5) } # 5,5
  context "math" do
    it "converts all paramter to floats on usage" do
      r = (one+0)
      r.gamma.should eql(7.0)
      r.cost.should eql(3.0)
    end
    context "+" do
      it "should be possible to add two ParameterSets" do
        result = one + other
        result.key.should == {gamma: 12.0, cost: 8.0, kernel: :rbf}
      end
      it "should be possible to add a Numeric" do
        result = one + 6
        result.key.should == {gamma: 13.0, cost: 9.0, kernel: :rbf}
      end
      it "should be possible to be added to a Numeric" do
        result = 7.0 + one
        result.key.should == {gamma: 14.0, cost: 10.0, kernel: :rbf}
      end
    end
    context "*" do
      it "should be possible to add two ParameterSets" do
        result = one * other
        result.key.should == {gamma: 35.0, cost: 15.0, kernel: :rbf}
      end
      it "should be possible to add a Numeric" do
        result = one * 6
        result.key.should == {gamma: 42.0, cost: 18.0, kernel: :rbf}
      end
      it "should be possible to be added to a Numeric" do
        result = 7.0 * one
        result.key.should == {gamma: 49.0, cost: 21.0, kernel: :rbf}
      end
    end
    context "-" do
      it "should be possible to add two ParameterSets" do
        result = one - other
        result.key.should == {gamma: 2.0, cost: -2.0, kernel: :rbf}
      end
      it "should be possible to add a Numeric" do
        result = one - 6
        result.key.should == {gamma: 1.0, cost: -3.0, kernel: :rbf}
      end
      it "should be possible to be added to a Numeric" do
        result = 7.0 - one
        result.key.should == {gamma: 0.0, cost: 4.0, kernel: :rbf}
      end
    end
    context "/" do
      it "should be possible to add two ParameterSets" do
        result = one / other
        result.key.should == {gamma: 1.4, cost: 0.6, kernel: :rbf}
      end
      it "should be possible to add a Numeric" do
        result = one / 8
        result.key.should == {gamma: 0.875, cost: 0.375, kernel: :rbf}
      end
      it "should be possible to be added to a Numeric" do
        result = 21 / one
        result.key.should == {gamma: 3.0, cost: 7.0, kernel: :rbf}
      end
    end
  end
  context "comparable" do
    it "should call result on both objects" do
      one.expects(:result)
      other.expects(:result)
      one > other
    end
    it "should call use the value of result" do
      one.stubs(:result).returns(10)
      other.stubs(:result).returns(5)
      (one > other).should be_true
    end
  end
  context "to_parameter" do
    let(:parameterset) { ParameterSet.new(2,3,:rbf) }
    it "should return a SvmParameter" do
      parameterset.to_parameter.should be_a(Libsvm::SvmParameter)
    end
  end
end