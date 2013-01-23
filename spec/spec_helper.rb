require 'bundler'
Bundler.setup
Bundler.require(:default, :test)
require 'svm_trainer'

include SvmTrainer

RSpec.configure do |config|
  config.mock_with :mocha
end
