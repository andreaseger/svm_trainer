module Trainer
  module Evaluator
    class GeometricMean < Base
      def initialize(model)
        super
        @store = Array.new(model.classes, {total: 0, correct: 0})
      end
      def evaluate_dataset(data)
        super

        @result = @store.values.reduce(1){|a,e| a*(e[:correct].quo(e[:total]))} ** (1.0/model.classes)
      end
      def add(actual, prediction)
        super()
        @store[actual][:total] += 1
        @store[actual][:correct] += 1 if actual == prediction
        self
      end
    end
  end
end
