require 'celluloid'
module Trainer
  #
  # Celluloid Worker Actor, which trains and evaluates a SVM
  #
  # @author Andreas Eger
  #
  class Worker
    include Celluloid

    def initialize args={}
      @evaluator = args[:evaluator]
    end


    #
    # train a SVM and evaluate it against the list of validation sets
    # @param  trainings_set [Problem] libsvm Problem
    # @param  params [ParameterSet] gamma, cost, kernel
    # @param  folds [Array] List of validation sets
    #
    # @return [model, results, params] libsvm model and merged results of the validation sets
    def train trainings_set, params, folds
      evaluate(Svm.svm_train(trainings_set, params.to_parameter), folds) << params
    rescue
      #TODO find out why this happens, seems to be something with the trainings_set inside the libsvm training
      p "error on #{trainings_set}|#{params}"
      return nil
    end


    #
    # evaluate the SVM for all validation sets and merge the results
    # @param  model libsvm Model
    # @param  folds [Array] validation sets
    #
    # @return [model, results] libsvm model and merged results
    def evaluate model, folds
      result = folds.map{ |fold|
        model.evaluate_dataset(fold, :evaluator => @evaluator)
      }.map(&:value).reduce(&:+) / folds.count
      return [model, result]
    end
  end
end
