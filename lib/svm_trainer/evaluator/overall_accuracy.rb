require_relative 'base'
module SvmTrainer
  module Evaluator
    class OverallAccuracy < Base
      def initialize(model)
        super
      end
      def add(actual, prediction)
        super()
        @correct += 1 if actual == prediction
        self
      end
      def result
        return 0.0 if @total.zero?
        @result ||= @correct / @total.to_f
      end
    end
  end
end
