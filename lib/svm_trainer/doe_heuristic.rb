require_relative 'base'
require_relative 'helper/doe_pattern'
module SvmTrainer
  #
  # Trainer for a parmeter search using a DOE heurisitc with the RBF kernel
  #
  # @author Andreas Eger
  #
  class DoeHeuristic < Base
    include DoePattern
    # default number of iterations to use during parameter search
    DEFAULT_MAX_ITERATIONS=3
    def name
      "Design of Experiments Heuristic with #{number_of_folds}-fold cross validation"
    end
    def label
      "doe_heuristic"
    end

    #
    # perform a parameter search with the DOE heuristic on the provided feature vectors
    # @param  feature_vectors
    # @param  max_iterations number of iterations used in this search
    #
    # @return [model, results] trained svm model and the results of the search
    def search feature_vectors, max_iterations=DEFAULT_MAX_ITERATIONS
      super(feature_vectors)

      # initialize iteration parameters and resolution
      parameter, resolution = pattern_for_range costs, gammas

      max_iterations.times do
        values = Hash.new { |h, k| h[k] = [] }
        parameter.each do |cost, gamma|
          # was this parameter pair already tested?
          params = ParameterSet.new(gamma, cost)
          next if results.has_key?(params.key)

          # n-fold cross validation
          @folds.each.with_index do |fold,index|
            # start async SVM training  | ( trainings_set, parameter, validation_sets)
            model, result, params = @worker.train( fold, params,
                                                   @folds.select.with_index{|e,ii| index!=ii } )
            next if model.nil?
            values[params.key] << result
          end
        end

        # calculate means for each parameter pair
        values = values.map{|k,v| {k => v.instance_eval { reduce(:+) / size.to_f }}}
        # flatten array of hashed into one hash
        results.merge! Hash[*values.map(&:to_a).flatten]

        # get the pair with the best value
        best = results.invert[results.values.max]

        p "best #{best}: #{results.values.max}"
        # get new search window
        parameter, resolution = pattern_for_center [best[:cost],best[:gamma]], resolution.map{|e| e/Math.sqrt(2)}, [costs, gammas]
      end

      best_parameter = ParameterSet.from_key results.invert[results.values.max]
      # retrain the model with the best results and all of the available data
      model = train_svm feature_vectors, best_parameter
      return model, results, best_parameter
    end
  end
end
