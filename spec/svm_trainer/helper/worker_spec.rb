require 'spec_helper'

describe Worker do
  let(:worker) { Worker.new(evaluator: :overall_accuracy) }
  before(:each) do
    Libsvm::Model.stubs(:train)
  end
  context "train" do
    let(:params) { OpenStruct.new(to_parameter: {gamma: 2}) }
    before(:each) do
      worker.wrapped_object.stubs(:evaluate).returns [:model, :results]
    end
    it "should call svm_train" do
      Libsvm::Model.expects(:train)
      worker.train(:trainings_set, params, [22,33])
    end
    it "should pass the params to svm_train" do
      Libsvm::Model.expects(:train).with(:trainings_set, params.to_parameter)
      worker.train(:trainings_set, params, [22,33])
    end
    it "should return three things" do
      worker.train(:trainings_set, params, [22,33]).should have(3).things
    end
  end
  context "evaluate" do
    let(:model) { DummyModel.new }
    let(:folds) { Array.new(3){Libsvm::Problem.new} }
    before(:each) do
      Evaluator::AllInOne.any_instance.expects(:evaluate_dataset).times(3).returns(rand)
    end
    it "should call evaluate_dataset on the model for each fold" do
      worker.evaluate(model, folds)
    end
    it "should calculate the mean of each fold's result" do
      _,result = worker.evaluate(model, folds)
      result.should be_a Float
      result.should be_between(0,1)
    end
  end
end