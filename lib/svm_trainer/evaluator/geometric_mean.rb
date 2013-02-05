require_relative 'base'
module SvmTrainer
  module Evaluator
    class GeometricMean < Base
      def initialize(model, verbose=false)
        super
        @store = Array.new(model.classes) { {total: 0, correct: 0} }
      end
      def add(actual, prediction)
        super()
        @store[actual][:total] += 1
        @store[actual][:correct] += 1 if actual == prediction
        self
      end
      def result
        return 0.0 if @total.zero?
        p @store if @verbose
        @result ||= @store.select{|e| e[:total] > 0 }
                                    .reduce(1){|a,e| a*(e[:correct].quo(e[:total]))} ** (1.quo(model.classes))
      end
    end
  end
end
