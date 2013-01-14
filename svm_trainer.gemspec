# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'svm_trainer/version'

Gem::Specification.new do |gem|
  gem.name          = "svm_trainer"
  gem.version       = SvmTrainer::VERSION
  gem.authors       = ["Andreas Eger"]
  gem.email         = ["dev@eger-andreas.de"]
  gem.description   = %q{Collection of methods to train a libsvm like SVM}
  gem.summary       = %q{Linear Search, Grid Search, DoE Heuristic, Nelder-Mead Heuristic}
  gem.homepage      = ""

  gem.add_dependency "celluloid"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
