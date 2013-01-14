require "spec_helper"
require 'trainer/base'

module Evaluator
  class OverallAccuracy
  end
end
describe Trainer::Base do
  let(:base) { Trainer::Base.new(costs: 2, gamma: 23) }
  before(:each) do
    Trainer::Base.any_instance.stubs(:build_problem)
  end
  context "#make_folds" do
    let(:number_of_folds) { 5 }

    it "should split the vectors into the correct number of folds" do
      base.number_of_folds = number_of_folds
      base.make_folds((1..100).to_a).should have(number_of_folds).things
    end
    it "should split the vectors when they can't be split into equal junks" do
      base.number_of_folds = number_of_folds
      base.make_folds((1..102).to_a).should have(number_of_folds).things
    end
  end
  context "#collect_results" do
    let(:futures) { FactoryGirl.build_list(:future, 10) }
    it "should return a hash" do
      base.collect_results(futures).should be_a(Hash)
    end
    it "should merge results of equal models" do
      f=FactoryGirl.build_list(:future, 10, value: [OpenStruct.new(cost: 10, gamma: -5), 10])
      base.collect_results(f).should have(1).keys
    end
    it "should calcualte mean of results of equal models" do
      f = 1.upto(5).map {|i| FactoryGirl.build(:future, value: [OpenStruct.new(cost: 10, gamma: -5), i*10]) }
      base.collect_results(f).values.first.should eq(30)
    end
  end
end