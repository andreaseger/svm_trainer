require "spec_helper"

describe Trainer::Base do
  let(:base) { Trainer::Base.new(costs: 2, gamma: 23) }
  before(:each) do
    Trainer::Base.any_instance.stubs(:build_problem)
  end
  def future(result, key)
    OpenStruct.new(
      value: [
        :model,
        result,
        OpenStruct.new(key: key)
      ]
    )
  end
  context "make_folds" do
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
  context "collect_results" do
    it "should return a hash" do
      futures = 1.upto(5).map { |i| future(i,2*i) }
      base.collect_results(futures).should be_a(Hash)
    end
    it "should merge results of equal models" do
      futures = 1.upto(10).map { |i| future(i,:all_the_same) }
      base.collect_results(futures).should have(1).keys
    end
    it "should calculate mean of results of equal models" do
      futures = 1.upto(5).map { |i| future(i*10,:all_the_same) }
      base.collect_results(futures).values.first.should eq(30)
    end
  end
end