source 'https://rubygems.org'

# Specify your gem's dependencies in svm_trainer.gemspec
gemspec

gem "rb-libsvm", '>=0.1.0', github: 'sch1zo/rb-libsvm', require: 'libsvm', platforms: :ruby
gem "jrb-libsvm", '>= 0.1.0', github: 'sch1zo/jrb-libsvm', platforms: :jruby

group :development do
  gem 'yard'
  gem 'kramdown'
  gem 'github-markup'

  gem 'pry'
  gem 'guard-rspec'
  gem 'guard-yard'

  gem 'rb-inotify', '~> 0.8.8', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false
end

group :test do
  gem 'pry'
  gem 'rake'
  gem 'mocha', require: 'mocha/api'
end
