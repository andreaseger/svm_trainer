require_relative 'base'
module SvmTrainer
  #
  # Trainer for a grid parmeter search with the RBF kernel
  #
  # @author Andreas Eger
  #
  class GridSearch < Base
    def name
      "Grid Search with #{number_of_folds}-fold cross validation"
    end
    def label
      "grid_search"
    end

    #
    # perform a grid search on the provided feature vectors
    # @param  feature_vectors
    #
    # @return [model, results] trained svm model and the results of the search
    def search feature_vectors,_
      super(feature_vectors)

      futures = []
      @gammas.each do |gamma|
        @costs.each do |cost|
          params = ParameterSet.new(gamma, cost)
          # n-fold cross validation
          @folds.each.with_index do |fold,index|
            # start async SVM training  | ( trainings_set, parameter, validation_sets)
            futures << @worker.future.train( fold, params,
                                            @folds.select.with_index{|e,ii| index!=ii } )
          end
        end
      end

      # collect results - !blocking!
      results = collect_results(futures)

      # get the pair with the best value
      best_parameter = ParameterSet.from_key results.invert[results.values.max]

      model = train_svm feature_vectors, best_parameter
      return model, results, best_parameter
    end
    def format_results results
      results.map{ |k,v| [k[:gamma], "#{k[:cost]} #{k[:gamma]} #{v}"] }
             .group_by{|e| e[0]}.values.map{|e| e.map{|f| f[1]}.join("\n")}.join "\n\n"
    end
  end
end