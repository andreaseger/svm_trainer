require 'bundler'
Bundler.setup
Bundler.require(:default, :test)
require 'svm_trainer'

include SvmTrainer

class DummyModel
  def classes
    2
  end
  def predict(arg)
    rand
  end
  def predict_probability(arg)
    [1,[rand, rand]]
  end
end

class DummyVector
  attr_accessor :label, :data
  def initialize
    @label = rand(0..1)
    @data = Array.new(5) {rand(0..1)}
  end
end

RSpec.configure do |config|
  config.mock_with :mocha
end
