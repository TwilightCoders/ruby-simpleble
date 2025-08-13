require 'mkmf'

# Simple, direct approach
if RUBY_PLATFORM =~ /mingw|mswin|cygwin/
  # Windows - use dynamic linking to avoid static library issues
  vendor_path = File.expand_path('../../vendor/simpleble', __dir__)
  
  # Build SimpleBLE first
  Dir.chdir(vendor_path) do
    system('utils\\build_lib.bat') || abort("Failed to build SimpleBLE")
  end
  
  # Add include paths
  inc_path = File.join(vendor_path, 'build_simpleble', 'install', 'include')
  $INCFLAGS << " -I#{inc_path} -I#{inc_path}/simpleble_c"
  
  # Use dynamic linking - let Windows find DLLs at runtime
  lib_path = File.join(vendor_path, 'build_simpleble', 'install', 'lib')
  $LDFLAGS << " -L#{lib_path} -lsimpleble-c"
  
  # System libraries
  $LDFLAGS << " -lole32 -loleaut32 -lws2_32 -liphlpapi -lbcrypt -lruntimeobject"
else
  # Unix - use standard static linking
  vendor_path = File.expand_path('../../vendor/simpleble', __dir__)
  
  Dir.chdir(vendor_path) do
    system('./utils/build_lib.sh simplecble') || abort('Failed to build SimpleBLE')
  end
  
  inc_path = File.join(vendor_path, 'install_simplecble', 'include')
  $INCFLAGS << " -I#{inc_path} -I#{inc_path}/simplecble"
  
  lib_path = File.join(vendor_path, 'install_simplecble', 'lib')
  $LDFLAGS << " #{lib_path}/libsimplecble.a"
  
  if RUBY_PLATFORM =~ /darwin/
    $LDFLAGS << " -framework Foundation -framework CoreBluetooth -framework IOBluetooth"
  else
    $LDFLAGS << " -ldbus-1 -lpthread"
  end
end

create_makefile('simpleble/simpleble')