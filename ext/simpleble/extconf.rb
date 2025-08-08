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
install_path = "#{vendor_path}/install_simplecble"

unless File.exist?("#{install_path}/lib/libsimplecble.a")
  puts "Building SimpleBLE library..."
  Dir.chdir(vendor_path) do
    case platform
    when :windows
      system('utils\\build_lib.bat simplecble') || abort("Failed to build SimpleBLE on Windows")
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
$LDFLAGS << " -lsimplecble"

# Link static libraries (needed for proper symbol resolution)
$LDFLAGS << " #{install_path}/lib/libsimplecble.a"

# Suppress warnings for cleaner compilation
$CXXFLAGS << ' -Wno-deprecated-declarations -Wno-unused-parameter'
$CFLAGS << ' -Wno-unused-parameter'

abort 'C standard library headers missing' unless have_header('string.h')

create_makefile('simpleble/simpleble')