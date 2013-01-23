source 'https://rubygems.org'

# Specify your gem's dependencies in svm_trainer.gemspec
gemspec

if RUBY_PLATFORM == 'java'
  gem "jrb-libsvm", github: 'sch1zo/jrb-libsvm', require: 'libsvm', platforms: :jruby
else
  gem "rb-libsvm",  github: 'sch1zo/rb-libsvm', branch: 'custom_stuff', require: 'libsvm', platforms: :ruby
end

group :development do
  gem 'yard'
  gem 'kramdown'
  gem 'github-markup'

  gem 'pry'
  gem 'guard-rspec'
  gem 'guard-yard'

  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false
end

group :test do
  gem 'pry'
  gem 'rake'
  gem 'mocha', require: 'mocha/api'
end