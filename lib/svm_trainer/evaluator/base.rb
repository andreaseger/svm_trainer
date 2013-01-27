module SvmTrainer
  module Evaluator
    class Base
      include Comparable
      attr_accessor :model
      def initialize(model)
        @model = model
        @correct = 0
        @total = 0
      end
      def evaluate_dataset(data)
        labels, examples = data.examples
        return 0.0 if labels.nil? || labels.empty?

        labels.each.with_index do |label,i|
          prediction = model.predict(examples[i])
          add(label, prediction)
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