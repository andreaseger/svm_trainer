require "svm_trainer/version"
if RUBY_PLATFORM == 'java'
  require 'jrb-libsvm'
else
  require 'libsvm'
end

require "svm_trainer/helper/parameter_set"
require "svm_trainer/linear_search"
require "svm_trainer/grid_search"
require "svm_trainer/doe_heuristic"
require "svm_trainer/nelder_mead"

require "svm_trainer/by_parameter"

require 'svm_trainer/evaluator/all_in_one'
