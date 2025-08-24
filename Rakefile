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

def copy_native_extension
  FileUtils.mkdir_p('lib/simpleble')
  dlext = RbConfig::CONFIG['DLEXT']
  src = File.join('ext', 'simpleble', "simpleble.#{dlext}")
  unless File.exist?(src)
    puts "❌ Built extension missing at #{src}"
    exit 1
  end
  dest = File.join('lib', 'simpleble', File.basename(src))
  FileUtils.cp(src, dest)
  puts "✅ Copied #{src} -> #{dest}"
  if RUBY_PLATFORM =~ /mswin|mingw|cygwin/
    # Copy SimpleBLE DLLs for Windows dynamic linking
    dlls = Dir['vendor/simpleble/build_simpleble/install/bin/*.dll']
    dlls.each do |dll|
      FileUtils.cp(dll, File.join('lib', 'simpleble', File.basename(dll)))
      puts "🔗 Copied dependency DLL #{dll}"
    end

    # Also copy any potential runtime DLLs from system
    %w[msvcr140.dll msvcp140.dll vcruntime140.dll].each do |sys_dll|
      system_paths = [
        "C:/Windows/System32/#{sys_dll}",
        "C:/Windows/SysWOW64/#{sys_dll}"
      ]
      system_paths.each do |path|
        if File.exist?(path)
          FileUtils.cp(path, File.join('lib', 'simpleble', sys_dll))
          puts "🔗 Copied system DLL #{path}"
          break
        end
      end
    end

    puts "ℹ️ No dependency DLLs found" if dlls.empty?
  end
end

desc "Compile the C extension"
task :compile do
  Dir.chdir('ext/simpleble') do
    reuse = ENV['SIMPLEBLE_REUSE_OBJECTS'] == '1'
    ruby 'extconf.rb'
    sh 'make clean' unless reuse
    sh(reuse ? 'make -j' : 'make')
  end
  copy_native_extension
end

desc "Install (alias for compile)"
task :install => :compile

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
    vendor/simpleble/simpleble/include/simpleble_c/simpleble.h
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
