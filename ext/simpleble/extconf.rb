require 'mkmf'
require 'fileutils'

$CXXFLAGS << ' -std=c++17 -O3 -Wall -Wextra'
$CFLAGS << ' -std=c99 -O3 -Wall -Wextra'

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
  if RbConfig::CONFIG['CC'] =~ /cl(\.exe)?$/i
    $CXXFLAGS << ' /EHsc /bigobj'
  else
    $CXXFLAGS << ' -fexceptions'
  end
  $LDFLAGS << ' -lole32 -loleaut32 -lws2_32 -liphlpapi -lbcrypt -lruntimeobject'
  
end

# Build SimpleBLE library if not present
vendor_path = File.expand_path('../../vendor/simpleble', __dir__)

# Different install paths for Windows vs Unix
install_path = case platform
when :windows
  "#{vendor_path}/build_simpleble/install"
else
  "#{vendor_path}/install_simplecble"  # Note: SimpleBLE creates "simplecble" (without P)
end

# Check for library existence (different file extensions on Windows)
# Note: SimpleBLE build system inconsistently spells the library name as "simbleble" (missing P)
library_file = case platform
when :windows
  "#{install_path}/lib/simpleble-c.lib" # Windows uses .lib files - simpleble-c
else
  "#{install_path}/lib/libsimplecble.a" # Unix uses .a files
end

puts "DEBUG: Looking for library at: #{library_file}"
puts "DEBUG: SKIP_VENDOR_BUILD = #{ENV['SKIP_VENDOR_BUILD']}"
puts "DEBUG: File exists? #{File.exist?(library_file)}"

unless File.exist?(library_file) || ENV['SKIP_VENDOR_BUILD'] == '1'
  puts "Building SimpleBLE library..."
  Dir.chdir(vendor_path) do
    case platform
    when :windows
      # Build SimpleBLE without platform specification to avoid Ninja generator issues
      puts "Building SimpleBLE for Windows (no arch specification to avoid Ninja conflicts)..."
      system("utils\\build_lib.bat") || abort("Failed to build SimpleBLE on Windows")
    else
      system('./utils/build_lib.sh simplecble') || abort("Failed to build SimpleBLE")
    end
  end
end

# Include directories - use only installed headers to avoid conflicts  
$INCFLAGS << " -I#{install_path}/include"
$INCFLAGS << " -I#{install_path}/include/simplecble"

# Library paths and linking  
$LDFLAGS << " -L#{install_path}/lib"

case platform
when :windows
  # Use the actual library name that SimpleBLE build system creates  
  $LDFLAGS << " -lsimpleble-c"  # simpleble-c
else
  $LDFLAGS << " -lsimplecble"
  # Link static libraries (needed for proper symbol resolution)
  $LDFLAGS << " #{install_path}/lib/libsimplecble.a"
end

# Suppress warnings for cleaner compilation
$CXXFLAGS << ' -Wno-deprecated-declarations -Wno-unused-parameter'
$CFLAGS << ' -Wno-unused-parameter'

# Skip header checks for now to test library linking
# TODO: Re-enable once compiler path is properly configured for mkmf
# abort 'C standard library headers missing' unless have_header('string.h')

create_makefile('simpleble/simpleble')