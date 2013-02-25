require 'spec_helper'

class DummyModel
  def classes
    2
  end
  def predict_probablility(arg)
    [rand, 0.8]
  end
end

describe Evaluator::AccuracyOverFalse(3) do
  let(:model) { DummyModel.new }
  let(:evaluator) { Evaluator::AccuracyOverFalse(0.7).new(model) }
  it "should be zero when no data provided" do
    evaluator.result.should == 0.0
  end
  it "should be 1.0 for one false entry" do
    evaluator.add(1,0)
    evaluator.result.should == 1.0
  end
  it "should be 0.5 for one right and one wrong entry" do
    evaluator.add(1,1)
    evaluator.add(1,0)
    evaluator.result.should == 0.5
  end
  it "should be able to chain adds" do
    evaluator.add(1,1).add(1,0)
    evaluator.result.should == 0.5
  end
  it "should exclude to low entries" do
    evaluator.add(1,0,0.6).add(1,0,0.5).add(1,0,0.65).add(0,1,0.7).add(0,1,0.8)
    evaluator.result.should == 0.4
  end
end
