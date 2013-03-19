module SvmTrainer
  #
  # Celluloid Worker Actor, which trains and evaluates a SVM
  #
  # @author Andreas Eger
  #
  class Worker

    def initialize args={}
      @evaluator_type = args[:evaluator]
    end


    #
    # train a SVM and evaluate it against the list of validation sets
    # @param  trainings_set [Problem] libsvm Problem
    # @param  params [ParameterSet] gamma, cost, kernel
    # @param  folds [Array<Array<FeatureVector>>] List of validation sets
    #
    # @return [model, results, params] libsvm model and merged results of the validation sets
    def train trainings_set, params, folds
      evaluate(::Libsvm::Model.train(trainings_set, params.to_parameter), folds) << params
    # rescue
    #   #TODO find out why this happens, seems to be something with the trainings_set inside the libsvm training
    #   p "error on #{trainings_set}|#{params}"
    #   return nil
    end


    #
    # evaluate the SVM for all validation sets and merge the results
    # @param  model libsvm Model
    # @param  folds [Array<Array<FeatureVector>>] validation sets
    #
    # @return [model, results] libsvm model and merged results
    def evaluate model, folds
      evaluator = Evaluator::AllInOne.new(model, @evaluator_type)
      result = folds.map{ |fold|
        evaluator.dup.evaluate_dataset(fold)
      }.reduce(&:+) / folds.count
      return [model, result]
    end
  end
end
