APPNAME = 'nrt-webui'

require 'colored'
require 'rake-pipeline'

desc "Serve files with rack"
task :server do
  sh 'bundle exec rackup'
end

desc "Build #{APPNAME}"
task :build do
  Rake::Pipeline::Project.new('Assetfile').invoke
end

desc "Clean"
task :clean do
  rm_rf 'tmp'
  rm_rf 'assets'
end

desc "Pack app in production mode"
task :dist do
  ENV['RAKEP_MODE'] = 'production'
  Rake::Pipeline::Project.new('Assetfile').invoke
end

desc "Run tests with PhantomJS"
task :test => :build do
  unless system("which phantomjs > /dev/null 2>&1")
    abort "PhantomJS is not installed. Download from http://phantomjs.org/"
  end

  cmd = "phantomjs tests/run-tests.js \"file://#{File.dirname(__FILE__)}/tests/index.html\""

  # Run the tests
  puts "Running #{APPNAME} tests"
  success = system(cmd)

  if success
    puts "Tests Passed".green
  else
    puts "Tests Failed".red
    exit(1)
  end
end
