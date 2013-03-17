require_relative 'base'
module SvmTrainer
  module Evaluator
    class AllInOne < Base
      def initialize(model, default_result=:geometric_mean, verbose=false)
        super(model, verbose)
        @default = default_result
        @store = []
      end

      def add(actual, prediction, probability=0.0)
        super()
        @store << [actual, prediction, probability]
        self
      end

      def result
        case @default
        when :geometric_mean
          geometric_mean
        when :overall_accuracy
          overall_accuracy
        when :mean_probability
          mean_probability
        else
          geometric_mean
        end
      end

      #
      # calculates geometric mean from internal store
      #
      # @return [Float] geometric mean
      def geometric_mean
        return 0.0 if @total.zero?
        @geometric_mean ||=
          @store.group_by{|e| e[0]}
                .map{|i,e| { total: e.count, correct: e.select{|i| i[0]==i[1]}.count} }
                .reduce(1){|a,e| a*ratio(e) } ** (1.quo(model.classes))
      end

      #
      # calculates false_positives
      # means original was false but verifier thought they were correct
      #
      # @return [Flaot] false_positives
      def false_positives
        return 0.0 if @total.zero?
        if @false_positives
          @false_positives
        else
          faulty = @store.select{|e| e[0] == 0 }
          @false_positives = faulty.select{|e| e[1] == 1}.count.quo(faulty.count)
        end
      end

      #
      # calculates false_negatives
      # means original was correct but verifier thought they were false
      #
      # @return [Float] false_negatives
      def false_negatives
        return 0.0 if @total.zero?
        if @false_negatives
          @false_negatives
        else
          correct = @store.select{|e| e[0] == 1 }
          @false_negatives = correct.select{|e| e[1] == 0}.count.quo(correct.count)
        end
      end

      #
      # calculates overall accuracy
      #
      # @return [Float] overall accuracy
      def overall_accuracy
        return 0.0 if @total.zero?
        @overall_accuracy ||=
          ratio( { total: @store.count, correct: @store.select{|e| e[0]==e[1]}.count }, true )
      end

      #
      # generates values for a histogram for the correctly predicted probabilities
      #
      # @return [Hash] histogram
      def histogram
        return {} if @total.zero?
        @histogram ||= @store.select{|e| e[0]==e[1]}
                              .group_by{|e| (e[2]/0.05).to_i }.sort
                              .map{|i,e| [i*5, e.size]}
      end

      #
      # generates values for a histogram for the false predicted probabilities
      #
      # @return [Hash] histogram
      def faulty_histogram
        return {} if @total.zero?
        @faulty_histogram ||= @store.select{|e| e[0]!=e[1]}
                              .group_by{|e| (e[2]/0.05).to_i }.sort
                              .map{|i,e| [i*5, e.size]}
      end

      #
      # merged results of correct and faulty histograms
      #
      # @return [Hash] histogram
      def full_histogram
        return {} if @total.zero?
        faulty_histogram.map{|k,v| [95-k,v]}.reverse + histogram
      end

      #
      # calculates the mean probability for the correctly predicted entries
      #
      # @return [Float] mean probability
      def mean_probability
        return 0.0 if @total.zero?
        @mean_probability ||= @store.select{|e| e[0]==e[1]}
                                    .reduce(1){|a,e| a*e[2]} ** 1.quo(@store.select{|e| e[0]==e[1]}.count)
                                    # .reduce(1){|a,e| a*e[2]} ** (1/(@store.select{|e| e[0]==e[1]}.count.to_f))
      end

      def metrics
        {
          geometric_mean: geometric_mean,
          false_positives: false_positives,
          false_negatives: false_negatives,
          overall_accuracy: overall_accuracy,
          mean_probability: mean_probability,
          correct_historgramm: histogram,
          faulty_histogram: faulty_histogram,
          full_histogram: full_histogram
        }
      end
      private
      def ratio obj, as_float=false
        ratio = obj[:correct].quo(obj[:total])
        as_float ? ratio.to_f : ratio
      end
    end
  end
end
