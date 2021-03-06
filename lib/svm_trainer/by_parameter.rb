require_relative 'base'
module SvmTrainer
  class ByParameter < Base
    def name
      "train svm by given parameters"
    end
    def label
      "ByParameter"
    end

    def train feature_vectors, parameter_set
      parameter_set.enable_probability!
      train_svm feature_vectors, parameter_set
    end
  end
end
