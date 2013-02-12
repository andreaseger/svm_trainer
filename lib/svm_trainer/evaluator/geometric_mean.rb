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
        if @verbose
          p @store
          if @store.count == 2
            p "false positives: #{1 - @store[0][:correct].quo(@store[0][:total])}"
            p "false negatives: #{1 - @store[1][:correct].quo(@store[1][:total])}"
          end
        end
        @result ||= @store.select{|e| e[:total] > 0 }
                                    .reduce(1){|a,e| a*(e[:correct].quo(e[:total]))} ** (1.quo(model.classes))
      end
    end
  end
end
