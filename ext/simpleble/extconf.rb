require 'mkmf'

# Set compilation flags for C++
$CXXFLAGS << ' -std=c++17 -O3 -Wall -Wextra'
$CFLAGS << ' -std=c99 -O3 -Wall -Wextra'

# Platform-specific flags
if RUBY_PLATFORM =~ /darwin/
  # macOS: Add framework paths and link to system Bluetooth framework
  $LDFLAGS << ' -framework Foundation -framework CoreBluetooth -framework IOBluetooth'
  $CXXFLAGS << ' -DSIMPLEBLE_MACOS'
elsif RUBY_PLATFORM =~ /linux/
  # Linux: Check for DBus (required for BlueZ)
  unless have_library('dbus-1')
    abort "DBus development libraries are required on Linux but not found. Install libdbus-1-dev"
  end
  $CXXFLAGS << ' -DSIMPLEBLE_LINUX'
  $LDFLAGS << ' -ldbus-1'
elsif RUBY_PLATFORM =~ /mswin|mingw|cygwin/
  # Windows
  $CXXFLAGS << ' -DSIMPLEBLE_WINDOWS'
  $LDFLAGS << ' -lole32 -loleaut32'
end

# Add vendor simpleble include paths
vendor_path = File.expand_path('../../vendor/simpleble', __dir__)
install_path = "#{vendor_path}/install_simplecble"

# Include directories
$INCFLAGS << " -I#{install_path}/include"
$INCFLAGS << " -I#{install_path}/include/simplecble"

# Library paths and linking
$LDFLAGS << " -L#{install_path}/lib"
$LDFLAGS << " -lsimplecble -lsimpleble"

# Static library linking (needed for macOS)
$LDFLAGS << " #{install_path}/lib/libsimplecble.a #{install_path}/lib/libsimpleble.a"

# Suppress warnings for cleaner compilation
$CXXFLAGS << ' -Wno-deprecated-declarations'
$CXXFLAGS << ' -Wno-unused-parameter'
$CFLAGS << ' -Wno-unused-parameter'

# Check basic compiler functionality
unless have_header('string.h')
  abort "C standard library headers not found"
end

# SimpleBLE libraries should be available - we use our own wrapper interface
# The built libraries are statically linked below

# Use wrapper approach - compile simpleble_wrapper.cpp instead of modifying vendor files
$objs = ['simpleble_wrapper.o', 'simpleble_ruby.o']

# Create the Makefile
create_makefile('simpleble/simpleble')
