require 'fileutils'

# Load gem specification
require_relative 'lib/simpleble/version'

task :default => :test

desc "Set up development environment"
task :setup do
  puts "Setting up ruby-simpleble development environment..."

  # Compile extension
  Rake::Task['compile'].invoke

  puts "✅ Development environment ready!"
end

desc "Compile the C extension"
task :compile do
  Dir.chdir('ext/simpleble') do
    ruby 'extconf.rb'
    sh 'make clean'
    sh 'make'
  end

  # Copy compiled extension to lib directory
  FileUtils.mkdir_p('lib/simpleble')
  compiled_ext = Dir.glob('ext/simpleble/simpleble.{bundle,so}').first
  if compiled_ext
    FileUtils.cp(compiled_ext, 'lib/simpleble/')
    puts "✅ Extension compiled and copied to lib/!"
  else
    puts "❌ Could not find compiled extension!"
    exit 1
  end
end

desc "Clean compiled files"
task :clean do
  Dir.chdir('ext/simpleble') do
    sh 'make clean' if File.exist?('Makefile')
    FileUtils.rm_f(Dir.glob('*.{o,bundle,so}'))
  end
  puts "✅ Cleaned compiled files!"
end

desc "Run tests"
task :test => :compile do
  sh "bundle exec rspec"
end

desc "Run tests including performance benchmarks"
task :test_performance => :compile do
  sh "bundle exec rspec --tag performance"
end

desc "Run all tests including performance"
task :test_all => :compile do
  sh "bundle exec rspec --tag performance --tag ~performance"
end

desc "Show vendor SimpleBLE status"
task :vendor_status do
  puts "📊 Vendor SimpleBLE submodule status:"
  sh "git submodule status"
  
  puts "\n🏷️ SimpleBLE version info:"
  if Dir.exist?('vendor/simpleble/.git')
    puts "  Git info:"
    sh "cd vendor/simpleble && git log --oneline -3"
    
    if File.exist?('vendor/simpleble/VERSION')
      version = File.read('vendor/simpleble/VERSION').strip
      puts "\n  SimpleBLE VERSION file: #{version}"
    end
  else
    puts "  ❌ Not a git submodule"
  end

  puts "\n📋 Key vendor files:"
  key_files = %w[
    vendor/simpleble/simpleble/include/simpleble/SimpleBLE.h
    vendor/simpleble/simplecble/include/simplecble/simpleble.h
    vendor/simpleble/install_simplecble/lib/libsimpleble.a
    vendor/simpleble/install_simplecble/lib/libsimplecble.a
  ]
  
  key_files.each do |file|
    if File.exist?(file)
      mtime = File.mtime(file)
      size = File.size(file)
      puts "  #{File.basename(file)}: #{mtime.strftime('%Y-%m-%d %H:%M:%S')} (#{size} bytes)"
    else
      puts "  #{File.basename(file)}: ❌ MISSING"
    end
  end
  
  puts "\n💡 To update vendor library:"
  puts "  git submodule update --remote vendor/simpleble"
end
