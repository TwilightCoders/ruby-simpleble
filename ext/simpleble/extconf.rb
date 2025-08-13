require 'mkmf'
require 'fileutils'

$CXXFLAGS << ' -std=c++17 -O3 -Wall -Wextra'
$CFLAGS   << ' -std=c99 -O3 -Wall -Wextra'

platform = case RUBY_PLATFORM
when /darwin/ then :macos
when /linux/ then :linux
when /mswin|mingw|cygwin/ then :windows
else :other
end

case platform
when :macos
  $CXXFLAGS << ' -DSIMPLEBLE_MACOS'
  $LDFLAGS  << ' -framework Foundation -framework CoreBluetooth -framework IOBluetooth'
when :linux
  unless have_library('dbus-1')
    abort 'libdbus-1-dev (DBus) is required on Linux'
  end
  $CXXFLAGS << ' -DSIMPLEBLE_LINUX'
  $LDFLAGS  << ' -ldbus-1 -lstdc++ -lpthread'
when :windows
  $CXXFLAGS << ' -DSIMPLEBLE_WINDOWS -D_WIN32_WINNT=0x0A00'
  if RbConfig::CONFIG['CC'] =~ /cl(\.exe)?$/i
    $CXXFLAGS << ' /EHsc /bigobj'
  else
    $CXXFLAGS << ' -fexceptions'
  end
  $LDFLAGS << ' -lole32 -loleaut32 -lws2_32 -liphlpapi -lbcrypt -lruntimeobject'
end

vendor_path = File.expand_path('../../vendor/simpleble', __dir__)
install_path = case platform
when :windows
  File.join(vendor_path, 'build_simpleble', 'install')
else
  File.join(vendor_path, 'install_simplecble')
end

# Allow using a prebuilt core library (from warmup job)
prebuilt_lib = ENV['SIMPLEBLE_PREBUILT_LIB']
if prebuilt_lib && File.exist?(prebuilt_lib)
  puts "Using prebuilt SimpleBLE core: #{prebuilt_lib}"
  $INCFLAGS << " -I#{install_path}/include"
  $INCFLAGS << " -I#{install_path}/include/simplecble"
  $LOCAL_LIBS << " #{prebuilt_lib}"
  abort 'C standard library headers missing' unless have_header('string.h')
  create_makefile('simpleble/simpleble')
  exit 0
end

# Build vendor library if missing
def build_vendor(platform, vendor_path)
  Dir.chdir(vendor_path) do
    case platform
    when :windows
      puts 'Building SimpleBLE (CMake/MSBuild)'
      system('utils\\build_lib.bat') || abort('Failed to build SimpleBLE on Windows')
    else
      system('./utils/build_lib.sh simplecble') || abort('Failed to build SimpleBLE')
    end
  end
end

expected_libs = []
case platform
when :windows
  expected_libs << File.join(install_path, 'lib', 'simpleble-c.lib')
else
  expected_libs << File.join(install_path, 'lib', 'libsimplecble.a')
end

unless expected_libs.all? { |f| File.exist?(f) } || ENV['SKIP_VENDOR_BUILD'] == '1'
  build_vendor(platform, vendor_path)
end

$INCFLAGS << " -I#{install_path}/include"
$INCFLAGS << " -I#{install_path}/include/simplecble"
$LDFLAGS  << " -L#{install_path}/lib"

case platform
when :windows
  $LDFLAGS << ' -lsimpleble-c'
else
  $LDFLAGS << ' -lsimplecble'
  # Also force static link path for clarity
  static_lib = File.join(install_path, 'lib', 'libsimplecble.a')
  $LDFLAGS << " #{static_lib}" if File.exist?(static_lib)
end

$CXXFLAGS << ' -Wno-deprecated-declarations -Wno-unused-parameter'
$CFLAGS   << ' -Wno-unused-parameter'

abort 'C standard library headers missing' unless have_header('string.h')

create_makefile('simpleble/simpleble')
