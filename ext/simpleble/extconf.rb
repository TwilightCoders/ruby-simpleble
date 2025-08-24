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

  # Create simpleble_c symlink to simplecble for header compatibility
  simpleble_c_path = File.join(inc_path, 'simpleble_c')
  simplecble_path = File.join(inc_path, 'simplecble')
  unless File.exist?(simpleble_c_path)
    if File.directory?(simplecble_path)
      File.symlink('simplecble', simpleble_c_path)
      puts "Created symlink: simpleble_c -> simplecble"
    end
  end

  lib_path = File.join(vendor_path, 'install_simplecble', 'lib')
  $LDFLAGS << " #{lib_path}/libsimplecble.a #{lib_path}/libsimpleble.a"

  # SimpleBLE is C++, so we need to link C++ standard library and runtime
  $LIBS << " -lstdc++ -lm"

  if RUBY_PLATFORM =~ /darwin/
    $LDFLAGS << " -framework Foundation -framework CoreBluetooth -framework IOBluetooth"
  else
    $LIBS << " -ldbus-1 -lpthread"
  end
end

create_makefile('simpleble/simpleble')
