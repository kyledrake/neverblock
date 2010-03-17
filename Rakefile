require 'rubygems'
require 'rake'

require 'spec'
require 'spec/rake/spectask'

desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/*_spec.rb']
  t.spec_opts = ["--format specdoc"]
end

task :default => :spec

Dir['tasks/*.rake'].each { |rake| load rake }
