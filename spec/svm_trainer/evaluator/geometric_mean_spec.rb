require 'spec_helper'

class DummyModel
  def classes
    2
  end
  def predict(arg)
    rand
  end
end

describe Evaluator::GeometricMean do
  let(:model) { DummyModel.new }
  let(:evaluator) { Evaluator::GeometricMean.new(model) }
  it "should be zero when no data provided" do
    evaluator.result.should == 0.0
  end
  it "should be 1.0 for one correct entry" do
    evaluator.add(1,1)
    evaluator.result.should == 1.0
  end
  it "should be 0.0 if one class is not once correct" do
    evaluator.add(1,1)
    evaluator.add(0,1)
    evaluator.result.should == 0.0
  end
  it "should calcuate the correct mean for three entries" do
    evaluator.add(0,0).add(0,1).add(1,1)
    evaluator.result.should be_within(0.01).of(0.707)
  end
  it "should calcuate the correct mean for five entries" do
    evaluator.add(0,0).add(0,1).add(1,1).add(1,1).add(1,0)
    #(1/2*2/3)**(1/2)
    evaluator.result.should be_within(0.01).of(0.577)
  end
  context "comparable" do
    let(:evaluator2) { Evaluator::GeometricMean.new(model) }
    before(:each) do
      evaluator.add(1,0).add(1,1).add(1,1).add(0,0)
      evaluator2.add(1,0).add(0,1).add(0,1).add(0,0)
    end
    it "should be able compare evaluators" do
      evaluator.should be > evaluator2
      evaluator2.should be < evaluator
    end
  end
end