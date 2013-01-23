require 'spec_helper'

class DummyModel
  def classes
    2
  end
  def predict(arg)
    rand
  end
end

describe Evaluator::Base do
  let(:model) { DummyModel.new }
  let(:evaluator) { Evaluator::Base.new(model) }
  let(:data) { OpenStruct.new(l: 3, x: [1,2,3], y: [9,8,7]) }
  it "should not fail" do
    Evaluator::Base.any_instance.stubs(:add)
    Evaluator::Base.any_instance.stubs(:result)
    ->{evaluator.evaluate_dataset(data)}.should_not raise_error
  end
end