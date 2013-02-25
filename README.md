# SvmTrainer

Collection of methods to train a libsvm like SVM.

- Linear Search for a linear kernel
- Grid Search for a RBF kernel
- DesignOfExperiments Heuristic for a RBF kernel
- Nelder-Mead Heuristic for a RBF kernel

Also see [SvmHelper](https://github.com/sch1zo/svm_helper)

## Dependencies

You need one of these two libsvm wrapper installed.
- [rb-libsvm][] ( a custom fork of the [original rb-libsvm][] )
- [jrb-libsvm][]

ideally you just add the following to your Gemfile:

``` ruby
gem "rb-libsvm", github: 'sch1zo/rb-libsvm', branch: 'custom_stuff', require: 'libsvm', platforms: :ruby
gem "jrb-libsvm", '>= 0.1.0', github: 'sch1zo/jrb-libsvm', platforms: :jruby
```

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


[rb-libsvm]:    https://github.com/sch1zo/rb-libsvm
[original rb-libsvm]:    https://github.com/febeling/rb-libsvm
[jrb-libsvm]:    https://github.com/sch1zo/jrb-libsvm