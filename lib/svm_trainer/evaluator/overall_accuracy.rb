module Trainer
  module Evaluator
    class OverallAccuracy < Base
      def evaluate_dataset(data)
        super

        @result = @correct / total
      end
      def add(actual, prediction)
        super()
        @correct += 1 if actual == prediction
        self
      end
    end
  end
end
