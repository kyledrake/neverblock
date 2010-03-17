require 'rubygems'
require 'rake'
require 'rake/testtask'

require 'spec'
require 'spec/rake/spectask'

desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/*_spec.rb']
  t.spec_opts = ["--format specdoc"]
end

desc "Run all tests"
Rake::TestTask.new do |t|
 #t.warning = true
 t.libs = ['lib', 'test']
 t.pattern = 'test/*_test.rb'
end

task :default => :spec

Dir['tasks/*.rake'].each { |rake| load rake }
