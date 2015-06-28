require 'fileutils'
require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new do |t|
  t.test_files = FileList['**/*_test.rb']
  t.verbose = true
end

namespace :hooks do
  desc 'Copies all hooks in `hooks/` to `.git-hooks/`'
  task :install do
    git_hooks = Dir.chdir(".git-hooks"){ Dir.pwd }
    hooks_dirs = ["hooks", "meta-hooks"]

    hooks_dirs.each do |hook_dir|
      Dir.chdir hook_dir do
        Dir.glob "**/*.rb" do |path|
          dest = "#{git_hooks}/#{path}"

          dest_dir = File.dirname dest
          FileUtils.mkdir_p(dest_dir) if !Dir.exists? dest_dir

          cp_r path, dest
        end
      end
    end
  end
end
