require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |task|
  task.libs << %w[test lib]
  task.pattern = 'test/**/*_test.rb'
  task.verbose = true
end

task :default => :test
