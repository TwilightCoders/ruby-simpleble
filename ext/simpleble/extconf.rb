require 'mkmf'
require 'fileutils'

# High-level strategy: compile SimpleBLE C++ and C wrapper sources directly from the
# vendor submodule instead of linking prebuilt libraries. We DO NOT commit those
# sources; we stage required .cpp files into a build-local tmp_src directory.

$CXXFLAGS << ' -std=c++17 -O3 -Wall -Wextra'
$CFLAGS << ' -std=c99 -O3 -Wall -Wextra'
$CXXFLAGS << ' -DSIMPLEBLE_BUILD'
$CFLAGS << ' -DSIMPLEBLE_BUILD'

platform = case RUBY_PLATFORM
when /darwin/ then :macos
when /linux/ then :linux
when /mswin|mingw|cygwin/ then :windows
else :other
end

# Platform defines & system linkage
case platform
when :macos
  $CXXFLAGS << ' -DSIMPLEBLE_MACOS'
  $LDFLAGS << ' -framework Foundation -framework CoreBluetooth -framework IOBluetooth'
when :linux
  unless have_library('dbus-1')
    abort 'libdbus-1-dev (DBus) is required on Linux'
  end
  $CXXFLAGS << ' -DSIMPLEBLE_LINUX'
  $LDFLAGS << ' -ldbus-1 -lstdc++ -lpthread'
when :windows
  $CXXFLAGS << ' -DSIMPLEBLE_WINDOWS'
  # Enable C++/WinRT (headers are header-only but need /EHsc and sometimes /bigobj)
  if RbConfig::CONFIG['CC'] =~ /cl(\.exe)?$/i
    $CXXFLAGS << ' /EHsc /bigobj'
  else
    $CXXFLAGS << ' -fexceptions'
  end
  # Link necessary Windows system libs; windowsapp provides WinRT activation
  $LDFLAGS << ' -lole32 -loleaut32 -lws2_32 -liphlpapi -lbcrypt -lruntimeobject'
end

simpleble_root = File.expand_path('../../vendor/simpleble/simpleble', __dir__)
src_root       = File.join(simpleble_root, 'src')
src_c_root     = File.join(simpleble_root, 'src_c')
include_root   = File.join(simpleble_root, 'include')

unless Dir.exist?(simpleble_root)
  abort "SimpleBLE submodule missing at #{simpleble_root}. Run: git submodule update --init --recursive"
end

# Include paths (C++ and C API headers)
$INCFLAGS << " -I#{include_root}"
$INCFLAGS << " -I#{include_root}/simpleble"
$INCFLAGS << " -I#{include_root}/simpleble_c"

# Ensure required export header exists (upstream layout may omit it depending on shallow vendor state)
export_header = File.join(include_root, 'simpleble', 'export.h')
unless File.exist?(export_header)
  FileUtils.mkdir_p(File.dirname(export_header))
  File.write(export_header, <<~H)
    #pragma once
    // Auto-generated minimal export header to satisfy SimpleBLE public includes.
    #if defined(_WIN32) || defined(_WIN64)
      #if defined(SIMPLEBLE_BUILD)
        #define SIMPLEBLE_EXPORT __declspec(dllexport)
      #else
        #define SIMPLEBLE_EXPORT __declspec(dllimport)
      #endif
    #else
      #if defined(__GNUC__) || defined(__clang__)
        #define SIMPLEBLE_EXPORT __attribute__((visibility("default")))
      #else
        #define SIMPLEBLE_EXPORT
      #endif
    #endif
  H
  puts "Generated missing simpleble/export.h"
end

# Select backend folders allowed per platform
allowed_backends = case platform
when :macos then %w[macos common]
when :linux then %w[linux common]
when :windows
  %w[windows common]
else %w[common]
end
excluded_backends = %w[android linux_legacy plain]

all_cpp = Dir.glob(File.join(src_root, '**', '*.cpp'))
filtered_cpp = all_cpp.select do |f|
  if f.include?('/backends/')
    b = f.split('/backends/').last.split('/').first
    next false if excluded_backends.include?(b)
    allowed_backends.include?(b)
  else
    true
  end
end

# Add C wrapper sources (exclude deprecated directory)
wrapper_cpp = Dir.glob(File.join(src_c_root, '*.cpp')).reject { |f| f =~ /DEPRECATED/ }

stage_dir = File.join(__dir__, 'tmp_src')
FileUtils.rm_rf(stage_dir)
FileUtils.mkdir_p(stage_dir)

copy_files = filtered_cpp + wrapper_cpp
copy_files.each do |src|
  rel = src.sub(src_root + '/', '').sub(src_c_root + '/', '')
  target = File.join(stage_dir, rel)
  FileUtils.mkdir_p(File.dirname(target))
  FileUtils.cp(src, target)
end

puts "Staged #{copy_files.size} SimpleBLE source files into tmp_src/ (platform=#{platform})"

# Windows now always attempts to build the real backend; if the required SDK/toolchain
# (C++/WinRT, Windows 10+ SDK) is missing, the build should fail rather than stub.

# Source list for mkmf (relative paths)
ext_sources = Dir.glob(File.join('tmp_src', '**', '*.cpp')) + ['simpleble_ruby.c']
$srcs = ext_sources
$objs = ext_sources.map { |s| File.basename(s).sub(/\.(cpp|c)$/,'') + '.o' }

# Suppress warnings for cleaner compilation
$CXXFLAGS << ' -Wno-deprecated-declarations -Wno-unused-parameter'
$CFLAGS << ' -Wno-unused-parameter'

abort 'C standard library headers missing' unless have_header('string.h')

create_makefile('simpleble/simpleble')
