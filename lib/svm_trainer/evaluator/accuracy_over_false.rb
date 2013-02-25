require_relative 'base'
module SvmTrainer
  module Evaluator
    def Evaluator.AccuracyOverFalse min_probability
      Class.new(Base) do
        @@min_probability = min_probability

        def initialize(model, verbose=false)
          super
          @correct_over = 0
        end
        def evaluate_dataset(data)
          return 0.0 if data.l.zero?

          labels, examples = data.examples
          data.l.times do |i|
            prediction,probability = model.predict_probability(examples[i])
            add(labels[i], prediction, probability.max)
          end
          return result
        end
        def add(actual, prediction, probability=@@min_probability)
          super()
          @correct += 1 if actual != prediction
          @correct_over += 1 if actual != prediction && probability >= @@min_probability
          self
        end
        def result
          return 0.0 if @total.zero?
          p({false: @correct, false_over: @correct_over, total: @total, min_probability: @@min_probability}) if @verbose
          @result ||= @correct_over / @total.to_f
        end
      end
    end
  end
end
