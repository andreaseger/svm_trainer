guard 'rspec', cli: "--color --format d", all_after_pass: false, rvm:['ruby-1.9.3-p362@svm_trainer', 'jruby-1.7.2@svm_trainer'] do
  watch(%r{^spec/.+_spec\.rb$})
  watch('lib/svm_trainer.rb')            { 'spec' }
  watch(%r{^lib/svm_trainer/(.+)\.rb$})               { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')            { 'spec' }
  watch('spec/factories.rb')              { 'spec' }
  watch(%r{^spec/factories/(.+)\.rb})     { 'spec' }
  watch(%r{^spec/support/(.+)_spec\.rb})  { |m| "spec/#{m[1]}s/*" }
end

notification :tmux,
  :display_message => true,
  :timeout => 3 # in seconds

# guard 'yard' do
#   watch(%r{lib/.+\.rb})
# end
