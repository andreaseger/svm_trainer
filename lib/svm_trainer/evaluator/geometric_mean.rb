module Trainer
  module Evaluator
    class GeometricMean
      attr_accessor :model
      def initialize(model)
        @model = model
        @correct = 0
        @store = Array.new(model.classes, {total: 0, correct: 0})
      end
      def evaluate_dataset(data)
        total = data.l
        return 0.0 if total.zero?

        total.times do |i|
          prediction = Svm.svm_predict(model, data.x[i])
          add(data.y[i], prediction)
        end

        @store.values.reduce(1){|a,e| a*(e[:correct].quo(e[:total]))} ** (1.0/model.classes)
      end
      def add(actual, prediction)
        @store[actual][:total] += 1
        @store[actual][:correct] += 1 if actual == prediction
      end
    end
  end
end
