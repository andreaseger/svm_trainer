require 'spec_helper'

class DummyModel
  def classes
    2
  end
  def predict(arg)
    rand
  end
end

describe Evaluator::OverallAccuracy do
  let(:model) { DummyModel.new }
  let(:evaluator) { Evaluator::OverallAccuracy.new(model) }
  it "should be zero when no data provided" do
    evaluator.result.should == 0.0
  end
  it "should be 100 for one correct entry" do
    evaluator.add(1,1)
    evaluator.result.should == 100.0
  end
  it "should be 50 for one right and one wrong entry" do
    evaluator.add(1,1)
    evaluator.add(1,0)
    evaluator.result.should == 50.0
  end
  it "should be able to chain adds" do
    evaluator.add(1,1).add(1,0)
    evaluator.result.should == 50.0
  end
  context "comparable" do
    let(:evaluator2) { Evaluator::OverallAccuracy.new(model) }
    before(:each) do
      evaluator.add(1,0).add(1,1).add(1,1).add(0,0)
      evaluator2.add(1,0).add(0,1).add(0,1).add(0,0)
    end
    it "should be able compare evaluators" do
      evaluator.should be > evaluator2
      evaluator2.should be < evaluator
    end
  end

  def test_geometric_mean
    performance = Evaluator::GeometricMean.new
    assert_equal(0.0, performance.value)
    performance.add_result(0, 0)
    assert_equal(1.0, performance.value)
    performance.add_result(0, 1)
    performance.add_result(1, 1)
    assert((0.707 - performance.value).abs < 0.01)
    performance.add_result(1, 1)
    performance.add_result(1, 0)
    assert((0.577 - performance.value).abs < 0.01)
  end

end