module Trainer
  module Evaluator
    class OverallAccuracy
      attr_accessor :model
      def initialize(model)
        @model = model
        @correct = 0
      end
      def evaluate_dataset(data)
        total = data.l
        return 0.0 if total.zero?

        total.times do |i|
          prediction = Svm.svm_predict(model, data.x[i])
          add(data.y[i], prediction)
        end

        @correct / total
      end
      def add(actual, prediction)
        @correct += 1 if actual == prediction
      end
    end
  end
end
