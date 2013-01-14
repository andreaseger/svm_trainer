require "spec_helper"
require 'trainer/nelder_mead'

module Evaluator
  class OverallAccuracy
  end
end
describe Trainer::NelderMead do
  let(:trainer) { Trainer::NelderMead.new({}) }
  before(:each) do
    trainer.stubs(:func).returns(1)
  end
  context "#reflect" do
    let(:center) { Trainer::ParameterSet.new(5,5) }
    it "should calculate the reflected point for (3,3) on (5,5)" do
      worst = Trainer::ParameterSet.new(3,3)
      r=trainer.reflect(center, worst).key
      r.should == {:gamma=>7.0, :cost=>7.0}
    end
    it "should calculate the reflected point for (7,3) on (5,5)" do
      worst = Trainer::ParameterSet.new(7,3)
      r=trainer.reflect(center, worst).key
      r.should == {:gamma=>3.0, :cost=>7.0}
    end
  end
  context "#expand" do
    it "should just call reflect with alpha=2.0" do
      trainer.expects(:reflect).with(111,222,2.0)
      trainer.expand(111,222)
    end
  end
  context "#contract" do
    context "#outside" do
      it "should just call reflect with alpha=0.5" do
        trainer.expects(:reflect).with(111,222,0.5)
        trainer.contract_outside(111,222)
      end
    end
    context "#inside" do
      let(:center) { Trainer::ParameterSet.new(5,5) }
      it "should calculate the reflected point for (3,3) on (5,5)" do
        worst = Trainer::ParameterSet.new(3,3)
        r=trainer.contract_inside(center, worst).key
        r.should == {:gamma=>4.0, :cost=>4.0}
      end
      it "should calculate the reflected point for (7,3) on (5,5)" do
        worst = Trainer::ParameterSet.new(7,3)
        r=trainer.contract_inside(center, worst).key
        r.should == {:gamma=>6.0, :cost=>4.0}
      end
    end
  end
end