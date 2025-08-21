require_relative 'simpleble/version'
require_relative 'simpleble/exceptions'

# Load the native extension
require_relative 'simpleble/simpleble'

# Load Ruby wrapper classes
require_relative 'simpleble/adapter'
require_relative 'simpleble/peripheral'
require_relative 'simpleble/service'
require_relative 'simpleble/characteristic'
require_relative 'simpleble/descriptor'

# Ensure SimpleBLE is available at top level
unless defined?(::SimpleBLE)
  raise LoadError, "SimpleBLE C extension did not load properly"
end

# Module-level convenience methods
module SimpleBLE
  # Get all available Bluetooth adapters
  def self.adapters
    Adapter.get_adapters
  end

  # Check if Bluetooth is enabled
  def self.bluetooth_enabled?
    Adapter.bluetooth_enabled?
  end

  # Quick scan for peripherals using first available adapter
  def self.scan(timeout_ms = 5000)
    adapters = self.adapters
    raise BluetoothNotAvailableError, "No Bluetooth adapters found" if adapters.empty?

    adapter = adapters.first
    adapter.scan_for(timeout_ms)
    adapter.scan_results
  end
end
