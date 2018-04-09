require "fileutils"
require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => :test

namespace :project do
  desc "Rebuilding Xcode test project"
  task rebuild: %w(remove create)

  desc "Create Xcode test project"
  task :create do
    Dir.chdir("test/test_project") do
      Dir.mkdir("TestProject") unless Dir.exist?("TestProject")
      exec("xcodegen")
    end
  end

  desc "Remove Xcode test project"
  task :remove do
    Dir.glob("test/test_project/*") do |path|
      FileUtils.rm_rf(path) unless File.file?(path)
    end
  end
end
