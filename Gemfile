source 'https://rubygems.org'

# Specify your gem's dependencies in svm_trainer.gemspec
gemspec

# gem "jrb-libsvm", git: 'git://github.com/sch1zo/jrb-libsvm.git',
#   require: 'libsvm', platforms: :jruby

gem "rb-libsvm",  git: 'git://github.com/sch1zo/rb-libsvm.git', branch: 'custom_stuff',
  require: 'libsvm', platforms: :ruby

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