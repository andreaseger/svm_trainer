require 'spec_helper'

class Svm
end

describe Trainer::Worker do
  let(:worker) { Trainer::Worker.new(evaluator: nil) }
  before(:all) do
    Svm.stubs(:svm_train)
  end
  context "train" do
    
  end
end