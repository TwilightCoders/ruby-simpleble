require 'mkmf'
require 'fileutils'

# Platform detection helpers
def windows?
  RUBY_PLATFORM =~ /mswin|mingw|cygwin/
end

def darwin?
  RUBY_PLATFORM =~ /darwin/
end

def linux?
  RUBY_PLATFORM =~ /linux/
end

# Platform-specific compiler flags
$CXXFLAGS << ' -std=c++17 -O3 -Wall -Wextra'
$CFLAGS   << ' -std=c99 -O3 -Wall -Wextra'

case RUBY_PLATFORM
when /darwin/
  $CXXFLAGS << ' -DSIMPLEBLE_MACOS'
  $LDFLAGS  << ' -framework Foundation -framework CoreBluetooth -framework IOBluetooth'
when /linux/
  unless have_library('dbus-1')
    abort 'libdbus-1-dev (DBus) is required on Linux'
  end
  $CXXFLAGS << ' -DSIMPLEBLE_LINUX'
  $LDFLAGS  << ' -ldbus-1 -lstdc++ -lpthread'
when /mswin|mingw|cygwin/
  $CXXFLAGS << ' -DSIMPLEBLE_WINDOWS -D_WIN32_WINNT=0x0A00'
  if RbConfig::CONFIG['CC'] =~ /cl(\.exe)?$/i
    $CXXFLAGS << ' /EHsc /bigobj'
  else
    $CXXFLAGS << ' -fexceptions'
  end
  $LDFLAGS << ' -lole32 -loleaut32 -lws2_32 -liphlpapi -lbcrypt -lruntimeobject'
end

# Build SimpleBLE library using its native build system
def build_simpleble
  vendor_path = File.expand_path('../../vendor/simpleble', __dir__)
  
  puts "Building SimpleBLE library..."
  Dir.chdir(vendor_path) do
    if windows?
      # Try building without platform specification first (avoids Ninja issues)
      unless system('utils\\build_lib.bat')
        # Fallback: auto-detect Windows architecture
        arch = case RUBY_PLATFORM
        when /i386/, /x86/ then 'x86'
        when /x86_64/, /x64/, /amd64/ then 'x64'
        else 'x64' # default to x64
        end
        system("utils\\build_lib.bat -arch #{arch}") || abort("Failed to build SimpleBLE on Windows")
      end
    else
      system('./utils/build_lib.sh simplecble') || abort('Failed to build SimpleBLE on Unix')
    end
  end
end

# Find SimpleBLE headers using mkmf - try multiple possible locations
def find_simpleble_headers
  header_paths = []
  
  # Add vendor install directories to search path
  vendor_path = File.expand_path('../../vendor/simpleble', __dir__)
  
  if windows?
    header_paths << File.join(vendor_path, 'build_simpleble', 'install', 'include')
  else
    header_paths << File.join(vendor_path, 'install_simplecble', 'include')
  end
  
  # Try to find the main adapter header in different subdirectories
  header_found = false
  
  # Windows typically uses simpleble_c/, Unix uses simplecble/
  %w[simpleble_c simplecble].each do |subdir|
    header_paths.each do |base_path|
      full_path = File.join(base_path, subdir)
      if File.directory?(full_path)
        $INCFLAGS << " -I#{base_path} -I#{full_path}"
        puts "Found SimpleBLE headers in: #{full_path}"
        header_found = true
        return subdir  # Return which subdirectory we found
      end
    end
  end
  
  unless header_found
    abort "SimpleBLE headers not found. Searched paths: #{header_paths.inspect}"
  end
end

# Find SimpleBLE libraries using mkmf
def find_simpleble_libraries
  vendor_path = File.expand_path('../../vendor/simpleble', __dir__)
  
  if windows?
    lib_path = File.join(vendor_path, 'build_simpleble', 'install', 'lib')
    puts "Searching for Windows SimpleBLE libraries in: #{lib_path}"
    
    # List what's actually in the directory
    if File.directory?(lib_path)
      Dir.entries(lib_path).each { |f| puts "  Found file: #{f}" }
    else
      abort "Library directory does not exist: #{lib_path}"
    end
    
    $LDFLAGS << " -L#{lib_path}"
    
    # Try to find and link the library file directly
    lib_file = File.join(lib_path, 'simpleble-c.lib')
    if File.exist?(lib_file)
      puts "Found library file: #{lib_file}"
      $LDFLAGS << " #{lib_file}"
    else
      # Try with have_library as fallback
      unless have_library('simpleble-c')
        abort "SimpleBLE library (simpleble-c) not found in #{lib_path}"
      end
    end
  else
    lib_path = File.join(vendor_path, 'install_simplecble', 'lib')
    puts "Searching for Unix SimpleBLE libraries in: #{lib_path}"
    
    # List what's actually in the directory  
    if File.directory?(lib_path)
      Dir.entries(lib_path).each { |f| puts "  Found file: #{f}" }
    else
      abort "Library directory does not exist: #{lib_path}"
    end
    
    $LDFLAGS << " -L#{lib_path}"
    
    # Try to link with simplecble library
    unless have_library('simplecble')
      abort "SimpleBLE library (simplecble) not found in #{lib_path}"
    end
  end
  
  puts "SimpleBLE library configuration completed for: #{lib_path}"
end

# Main build process
unless ENV['SKIP_VENDOR_BUILD'] == '1'
  build_simpleble
end

# Use mkmf to find headers and libraries
header_subdir = find_simpleble_headers
find_simpleble_libraries

# Add platform-specific warning suppressions
$CXXFLAGS << ' -Wno-deprecated-declarations -Wno-unused-parameter'
$CFLAGS   << ' -Wno-unused-parameter'

# Verify we can find basic system headers
abort 'C standard library headers missing' unless have_header('string.h')

# Create the Makefile
create_makefile('simpleble/simpleble')

puts ""
puts "SimpleBLE Ruby extension configured successfully!"
puts "Platform: #{RUBY_PLATFORM}"
puts "Header subdirectory: #{header_subdir}"
puts ""