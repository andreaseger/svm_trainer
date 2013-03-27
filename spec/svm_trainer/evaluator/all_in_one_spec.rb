require 'spec_helper'

class DummyModel
  def classes
    2
  end
  def predict(arg)
    rand
  end
end

describe Evaluator::AllInOne do
  let(:model) { DummyModel.new }
  context "geometric_mean" do
    let(:evaluator) { Evaluator::AllInOne.new(model, :geometric_mean) }
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
      let(:evaluator2) { Evaluator::AllInOne.new(model, :geometric_mean) }
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
  context "overall_accuracy" do
    let(:evaluator) { Evaluator::AllInOne.new(model, :accuracy) }
    it "should be zero when no data provided" do
      evaluator.result.should == 0.0
    end
    it "should be 1.0 for one correct entry" do
      evaluator.add(1,1)
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
    context "comparable" do
      let(:evaluator2) { Evaluator::AllInOne.new(model, :accuracy) }
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
  context "mean_probability" do
    let(:evaluator) { Evaluator::AllInOne.new(model) }
    it "should calculate the geometric mean for all correct probabilities" do
      evaluator.add(1,0,0.6).add(1,1,0.7).add(1,1,0.8).add(0,0,0.9)
      evaluator.mean_probability.should be_within(0.01).of(0.795)
    end
  end
  context "histogram" do
    let(:evaluator) { Evaluator::AllInOne.new(model) }
    it "should generate a histogram for correct entries" do
      evaluator.add(1,1,0.61).add(1,1,0.63).add(1,1,0.81).add(0,0,0.93)
      evaluator.add(1,1,0.66).add(1,1,0.62).add(1,1,0.74).add(0,0,0.94)
      # these entries should be ignored
      evaluator.add(1,0,0.61).add(0,1,0.63).add(1,0,0.81).add(1,0,0.93)
      evaluator.histogram.should == [[60, 3], [65, 1], [70, 1], [80, 1], [90, 2]]
    end
    it "should generate a histogram for faulty entries" do
      evaluator.add(1,0,0.61).add(0,1,0.63).add(1,0,0.81).add(1,0,0.93)
      evaluator.add(1,0,0.66).add(0,1,0.62).add(0,1,0.74).add(1,0,0.94)
      # these entries should be ignored
      evaluator.add(1,1,0.61).add(1,1,0.63).add(1,1,0.81).add(0,0,0.93)
      evaluator.faulty_histogram.should == [[60, 3], [65, 1], [70, 1], [80, 1], [90, 2]]
    end
    it "should generate a histogram for all entries" do
      evaluator.add(1,0,0.61).add(0,1,0.63).add(1,0,0.81).add(1,0,0.93)
      evaluator.add(1,0,0.66).add(0,1,0.62).add(0,1,0.74).add(1,0,0.94)
      evaluator.add(1,1,0.61).add(1,1,0.63).add(1,1,0.81).add(0,0,0.93)
      evaluator.add(1,1,0.66).add(1,1,0.62).add(1,1,0.74).add(0,0,0.94)
      evaluator.full_histogram.should == [[5, 2], [15, 1], [25, 1], [30, 1], [35, 3], [60, 3], [65, 1], [70, 1], [80, 1], [90, 2]]
    end
  end
  context "mean_probability" do
    let(:evaluator) { Evaluator::AllInOne.new(model) }
    it "should calculate the mean of the probabilities" do
      evaluator.add(1,1,0.61).add(1,1,0.63).add(1,1,0.81).add(0,0,0.93)
      evaluator.mean_probability.should be_within(0.001).of(0.745)
    end
  end
end
