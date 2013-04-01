require_relative 'base'
module SvmTrainer
  module Evaluator
    class AllInOne < Base
      attr_accessor :store
      def initialize(model, default_result=:mcc, verbose=false)
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
        when :precision
          precision
        when :f_5
          f_measure(0.5)
        when :f1
          f_measure
        when :f2
          f_measure(2.0)
        when :mcc
          mcc
        when :normalized_mcc
          normalized_mcc
        when :accuracy
          accuracy
        else
          mcc
        end
      end

      #
      # calculates geometric mean from internal store
      #
      # @return [Numeric] geometric mean
      def geometric_mean
        return 0.5 if @total.zero?
        @geometric_mean ||=
          @store.group_by{|e| e[0]}
                .map{|i,e| { total: e.count, correct: e.select{|i| i[0]==i[1]}.count} }
                .reduce(1){|a,e| a*ratio(e) } ** (1.quo(model.classes))
      end

      #
      # calculates false_positives
      # means original was false but verifier thought they were correct
      #
      # @return [Numeric] false positives
      def false_positives
        return 0.0 if @total.zero?
        @false_positives ||= @store.select{|e| e[0] == 0 && e[1] == 1}.count
      end

      #
      # calculates the false positives rate
      # false_positives / count_negatives
      #
      # @return [Numeric] false_positive_rate
      def false_positive_rate
        return 0.0 if @total.zero?
        @fpr ||= false_positives.quo(count_negatives)
      end

      #
      # calculates true positives
      # means original was true and agreed
      #
      # @return [Numeric] true_positives
      def true_positives
        return 0.0 if @total.zero?
        @true_positives ||= @store.select{|e| e[0] == 1 && e[1] == 1}.count
      end

      #
      # calculates true positive rate
      # true_positives / count_positives
      #
      # @return [Numeric] true_positives
      def true_positive_rate
        return 0.0 if @total.zero?
        @tpr ||= true_positives.quo(count_positives)
      end

      #
      # calculates false_negatives
      # means original was correct but verifier thought they were false
      #
      # @return [Numeric] false_negatives
      def false_negatives
        return 0.0 if @total.zero?
        @false_negatives ||= @store.select{|e| e[0] == 1 && e[1] == 0}.count
      end

      #
      # calculates the false_negatives rate
      # false_negatives / count_positives
      #
      # @return [Numeric] false_negative_rate
      def false_negative_rate
        return 0.0 if @total.zero?
        @fnr ||= false_negatives.quo(count_positives)
      end

      #
      # calculates true negatives
      # means original was false and verifier agrees
      #
      # @return [Numeric] false_negatives
      def true_negatives
        return 0.0 if @total.zero?
        @true_negatives ||= @store.select{|e| e[0] == 0 && e[1] == 0}.count
      end

      #
      # calculates the true negative rate
      # true_negatives / count_negatives
      #
      # @return [Numeric] false_negative_rate
      def true_negative_rate
        return 0.0 if @total.zero?
        @tnr ||= true_negatives.quo(count_negatives)
      end

      #
      # calculates precision
      # #correct/#all classified as correct
      #
      # @return [Numeric] overall accuracy
      def precision
        return 0.5 if [@total, true_positives].any?(&:zero?)
        @precision ||= true_positives.quo(true_positives + false_positives)
      end
      alias_method :recall, :true_positive_rate

      def accuracy
        return 0.5 if @total.zero?
        @accuracy ||= (true_positives + true_negatives).quo(@store.count)
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
      # @return [Numeric] mean probability
      def mean_probability
        return 0.0 if @total.zero?
        @mean_probability ||= @store.select{|e| e[0]==e[1]}
                                    .reduce(0){|a,e| a+e[2]} / (@store.select{|e| e[0]==e[1]}.count)
      end

      # F-beta score
      # harmonic mean of precision and recall
      # http://en.wikipedia.org/wiki/F1_score
      def f_measure(beta=1.0)
        return 0.5 if @total.zero?
        (1+beta**2) * (precision * recall).quo((beta**2) * precision + recall)
      end

      # Matthews correlation coefficient
      # http://en.wikipedia.org/wiki/Matthews_correlation_coefficient
      # it returns a value between −1 and +1.
      # +1 represents a perfect prediction
      # 0 no better than random prediction
      # −1 indicates total disagreement between prediction and observation.
      def mcc
        return 0.0 if [@total, true_positives, true_negatives, false_positives, false_negatives].any?(&:zero?)
        @mcc ||= (true_positives * true_negatives - false_positives * false_negatives).quo(
                  Math.sqrt((true_positives + false_positives) *
                            (true_positives + false_negatives) *
                            (true_negatives + false_positives) *
                            (true_negatives + false_negatives) ) )
      end
      # move the result of mcc into the interval 0..1
      def normalized_mcc
        (mcc+1)/2.0
      end
      def metrics
        {
          geometric_mean: geometric_mean,
          rates: {  fpr: false_positive_rate.to_f,
                    tpr: true_positive_rate.to_f,
                    fnr: false_negative_rate.to_f,
                    tnr: true_negative_rate.to_f },
          precision: precision.to_f,
          recall: recall.to_f,
          accuracy: accuracy.to_f,
          f_5: f_measure(0.5).to_f,
          f1: f_measure.to_f,
          f2: f_measure(2.0).to_f,
          matthews_correlation_coefficient: mcc,
          normalized_matthews_correlation_coefficient: normalized_mcc,
          mean_probability: mean_probability,
          correct_historgramm: histogram,
          faulty_histogram: faulty_histogram,
          full_histogram: full_histogram
        }
      end
      private
      def ratio obj, as_Numeric=false
        ratio = obj[:correct].quo(obj[:total])
        as_Numeric ? ratio.to_f : ratio
      end
      def count_positives
        @pos ||= @store.select{|e| e[0] == 1 }.count
      end
      def count_negatives
        @neg ||= @store.select{|e| e[0] == 0 }.count
      end
    end
  end
end
