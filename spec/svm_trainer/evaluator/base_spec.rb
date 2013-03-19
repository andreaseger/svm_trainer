require 'spec_helper'

class DummyVector
  attr_accessor :label, :data
  def initialize
    @label = rand(0..1)
    @data = Array.new(5) {rand(0..1)}
  end
end

describe Evaluator::Base do
  let(:model) { DummyModel.new }
  let(:evaluator) { Evaluator::Base.new(model) }
  let(:vectors) { Array.new(3){ DummyVector.new } }
  let(:data) {
    prop = Libsvm::Problem.new
    prop.tap{|p|
      p.set_examples(vectors.map(&:label), vectors.map{|e|
        Libsvm::Node.features(e.data)
      })
    }
  }
  it "should not fail" do
    Evaluator::Base.any_instance.stubs(:add)
    Evaluator::Base.any_instance.stubs(:result)
    ->{ evaluator.evaluate_dataset(data) }.should_not raise_error
  end
end
