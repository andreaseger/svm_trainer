module SvmTrainer
  module Evaluator
    class Base
      include Comparable
      attr_accessor :model
      def initialize(model, verbose = false)
        @model = model
        @correct = 0
        @total = 0
        @verbose = verbose
      end
      def evaluate_dataset(data)
        return 0.0 if data.l.zero?

        labels, examples = data.examples
        data.l.times do |i|
          prediction = model.predict(examples[i])
          add(labels[i], prediction)
        end
        return result
      end
      def add
        @total += 1
      end
      def <=>(other)
        self.result <=> other.result
      end
    end
  end
end
