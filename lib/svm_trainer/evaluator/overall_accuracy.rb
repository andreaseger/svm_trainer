require_relative 'base'
module SvmTrainer
  module Evaluator
    class OverallAccuracy < Base
      def add(actual, prediction)
        super()
        @correct += 1 if actual == prediction
        self
      end
      def result
        return 0.0 if @total.zero?
        p({correct: @correct, total: @total}) if @verbose
        @result ||= @correct / @total.to_f
      end
    end
  end
end
