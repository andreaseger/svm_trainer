module Trainer
  module Evaluator
    class Base
      attr_accessor :model
      attr_reader :result
      def initialize(model)
        @model = model
        @correct = 0
        @total = 0
      end
      def evaluate_dataset(data)
        total = data.l
        return 0.0 if total.zero?

        total.times do |i|
          prediction = model.predict(data.x[i])
          add(data.y[i], prediction)
        end
      end
      def add
        @total += 1
      end
    end
  end
end