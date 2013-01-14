require 'bundler'
Bundler.setup
Bundler.require(:default, :test)
require 'svm_trainer'

RSpec.configure do |config|
  config.mock_with :mocha

  FactoryGirl.find_definitions
end
