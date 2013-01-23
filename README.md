# SvmTrainer

Collection of methods to train a libsvm like SVM.

- Linear Search for a linear kernel
- Grid Search for a RBF kernel
- DesignOfExperiments Heuristic for a RBF kernel
- Nelder-Mead Heuristic for a RBF kernel

Also see [SvmHelper](https://github.com/sch1zo/svm_helper)

## Installation

Add this line to your application's Gemfile:

    gem 'svm_trainer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install svm_trainer

## Usage

Create a Object for one of the Algorithms and provide it with a Array of FeatureVectors.
The `search` should do everything on its own and provide a nicely trained SVM.
In addition search provides a list of all intermediate results from the parameter search.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
