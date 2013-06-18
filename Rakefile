require 'bundler'

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w(-c -f doc)
end

task :default => :spec
