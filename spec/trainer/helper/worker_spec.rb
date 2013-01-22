require 'spec_helper'

describe SvmTrainer::Worker do
  let(:worker) { SvmTrainer::Worker.new(evaluator: nil) }
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
    let(:model) { mock('model') }
    let(:folds) { [:a,:b,:c] }
    before(:each) do
      model.stubs(:evaluate_dataset).returns(OpenStruct.new(value: 42))
    end
    it "should call evaluate_dataset on the model for each fold" do
      model.expects(:evaluate_dataset).times(3).returns(OpenStruct.new(value: 42))
      worker.evaluate(model, folds)
    end
    it "should calculate the mean of each fold's result" do
      _,result = worker.evaluate(model, folds)
      result.should == 42
    end
  end
end