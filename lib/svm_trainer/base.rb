require 'celluloid'
require_relative 'helper/worker'

module Trainer
  #
  # Trainer Base Class
  #
  # @author Andreas Eger
  #
  class Base
    include Helper
    # default number of folds to use for cross validation
    DEFAULT_NUMBER_OF_FOLDS = 3
    attr_accessor :number_of_folds
    attr_accessor :results
    attr_accessor :costs
    attr_accessor :gammas
    attr_accessor :evaluator

    #
    # initialize a trainer
    # @param  args [Hash]
    # @option args [Range] :costs (-5..15) Range in which to search for the cost parameter
    # @option args [Range] :gammas (-15..9) Range in which to search for the gamma parameter
    # @option args [Evaluator] :evaluator (::Evaluator::OverallAccuracy) in `::Evaluator::OverallAccuracy`, `::Evaluator::GeometricMean`
    # @option args [Integer] :number_of_folds (DEFAULT_NUMBER_OF_FOLDS) how many folds to make
    #
    def initialize args
      @results = {}
      @costs = args.fetch(:costs) { -5..15 }
      @gammas = args.fetch(:gammas) { -15..9 }
      @evaluator = args.fetch(:evaluator, ::Evaluator::OverallAccuracy)
      @number_of_folds = args.fetch(:number_of_folds) { DEFAULT_NUMBER_OF_FOLDS }
    end

    #
    # splits the feature_vectors in equally sized parts
    # @param  feature_vectors [Array<FeatureVector>]
    #
    # @return [Array<Array<FeatureVector>>]
    def make_folds feature_vectors
      feature_vectors.each_slice(feature_vectors.size/number_of_folds).map do |set|
        build_problem set
      end.first(number_of_folds)
    end

    #
    # collect the celluloid futures and merge the results for a parameter pair
    # @param  futures [Array<Celluloid::Future>] list of Celluloid futures
    #
    # @return [Hash] keys are the parameter pairs, values are the results
    def collect_results futures
      # init a hash which automatically expands to something like {a:[], b:[]}
      values = Hash.new { |h, k| h[k] = [] }
      # get the results and put them into the Hash
      futures.map { |f|
        model, result = f.value # this is the actual blocking call
        next if model.nil?
        values[cost: model.cost, gamma: model.gamma] << result
      }
      # calculate means for each parameter pair
      values = values.map{|k,v| {k => v.instance_eval { reduce(:+) / size.to_f }}}
      # flatten array of hashed into one hash
      Hash[*values.map(&:to_a).flatten]
    end

    def format_results(results)
      results.to_json
    end

    private

    def train_svm feature_vector, params
      feature_set = build_problem feature_vector
      Svm.svm_train(feature_set, build_parameter(params) )
    end

    def build_problem set
      Problem.from_array(set.map(&:data), set.map(&:label))
    end

    def build_parameter args
      cost = args[:cost]
      gamma = args[:gamma]
      kernel =  case args[:kernel]
                when :linear
                  Parameter::LINEAR
                when :rbf
                  Parameter::RBF
                else
                  Parameter::RBF
                end

      Parameter.new(svm_type: Parameter::C_SVC,
                    kernel_type: kernel,
                    cost: cost,
                    gamma: gamma,
                    probability: 1)
    end
  end
end
