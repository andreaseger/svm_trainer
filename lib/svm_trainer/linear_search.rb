require_relative 'base'
module SvmTrainer
  #
  # Trainer for a linear parmeter search with a LINEAR kernel
  #
  # @author Andreas Eger
  #
  class Linear < Base
    def name
      "Linear Search with #{number_of_folds}-fold cross validation (linear kernel)"
    end
    def label
      "linear_search"
    end


    #
    # perform a parameter search on a linear kernel
    # @param  feature_vectors
    #
    # @return [model, results] trained svm model and the results of the search
    def search feature_vectors,_
      super(feature_vectors)

      values = Hash.new { |h, k| h[k] = [] }
      @costs.each do |cost|
        params = ParameterSet.new(0, cost, :linear)
        # n-fold cross validation
        @folds.each.with_index do |fold,index|
          # start async SVM training  | ( trainings_set, parameter, validation_sets)
          model, result, _ = @worker.train( fold, params,
                                                @folds.select.with_index{|e,ii| index!=ii } )
          next if model.nil?
          values[params.key] << result
        end
      end

      # calculate means for each parameter pair
      values = values.map{|k,v| {k => v.instance_eval { reduce(:+) / size.to_f }}}
      # flatten array of hashed into one hash
      results = Hash[*values.map(&:to_a).flatten]

      # get the pair with the best value
      best_parameter = ParameterSet.from_key results.invert[results.values.max]

      model = train_svm feature_vectors, best_parameter
      return model, results, best_parameter
    end
  end
end
