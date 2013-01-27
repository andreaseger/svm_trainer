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
  let(:data) { OpenStruct.new(examples: [[1,0,1],[34,65,12]] ) }
  it "should not fail" do
    Evaluator::Base.any_instance.stubs(:add)
    Evaluator::Base.any_instance.stubs(:result)
    ->{evaluator.evaluate_dataset(data)}.should_not raise_error
  end
end