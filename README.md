[![Gem Version](https://badge.fury.io/rb/simpleble.svg)](https://badge.fury.io/rb/simpleble)
[![CI](https://github.com/twilightcoders/ruby-simpleble/actions/workflows/ci.yml/badge.svg)](https://github.com/twilightcoders/ruby-simpleble/actions/workflows/ci.yml)
[![Maintainability](https://qlty.sh/badges/c8eaf08b-1a66-411f-b4c9-83be9446a564/maintainability.svg)](https://qlty.sh/gh/TwilightCoders/projects/ruby-simpleble)
[![Test Coverage](https://qlty.sh/badges/c8eaf08b-1a66-411f-b4c9-83be9446a564/test_coverage.svg)](https://qlty.sh/gh/TwilightCoders/projects/ruby-simpleble/metrics/code?)
[![GitHub License](https://img.shields.io/github/license/twilightcoders/ruby-simpleble)](https://github.com/twilightcoders/blob/ruby-simpleble/LICENSE.md)

# SimpleBLE Ruby

A Ruby gem providing enterprise-grade, cross-platform Bluetooth Low Energy (BLE) functionality through Ruby bindings for the [SimpleBLE](https://github.com/OpenBluetoothToolbox/SimpleBLE) C++ library. Delivers production-ready BLE scanning, device connection, and GATT operations.

## 🚀 Quick Start

```bash
gem install simpleble
```

```ruby
require 'simpleble'

# Check if Bluetooth is available
SimpleBLE.bluetooth_enabled?  # => true

# Get available Bluetooth adapters  
adapters = SimpleBLE.adapters
adapter = adapters.first
puts adapter.identifier       # => "Default Adapter [uuid]"

# Quick scan for BLE devices (5 second timeout)
devices = SimpleBLE.scan(5000)
puts "Found #{devices.length} BLE devices!"

# Advanced scanning with adapter control
adapter.scan_for(3000)       # Scan for 3 seconds
peripherals = adapter.scan_results
peripherals.each do |device|
  puts "Device: #{device.identifier} (#{device.address})"
end
```

## ✨ Features

### 🌐 **Cross-Platform Support**
- **macOS** - CoreBluetooth framework integration
- **Linux** - DBus/BlueZ backend support  
- **Windows** - WinRT Bluetooth APIs *(ready for testing)*

### 🔍 **BLE Operations**
- ✅ **Bluetooth adapter discovery and management**
- ✅ **Device scanning with timeout control**  
- ✅ **Real-time device discovery**
- ✅ **RSSI and connection status monitoring**
- 🚧 **GATT service/characteristic operations** *(in development)*
- 🚧 **Device connection and bonding** *(in development)*

### 🏗️ **Production Ready**
- ✅ **Memory-safe C extension with proper lifecycle management**
- ✅ **Comprehensive exception hierarchy for error handling**
- ✅ **Thread-safe operations**
- ✅ **RSpec test suite with 84%+ coverage**
- ✅ **Cross-platform build system**

## 🛠️ Installation

### Prerequisites

**macOS:**
- Xcode command line tools: `xcode-select --install`

**Linux:**
```bash
# Ubuntu/Debian
sudo apt-get install build-essential libdbus-1-dev cmake

# Red Hat/CentOS
sudo yum install gcc-c++ dbus-devel cmake
```

**Windows:**
- Visual Studio Build Tools
- Windows SDK
- CMake

### Install the Gem

```bash
gem install simpleble
```

Or add to your Gemfile:
```ruby
gem 'simpleble'
```

## 📖 API Documentation

### Module-Level Methods

```ruby
# Check Bluetooth availability
SimpleBLE.bluetooth_enabled?  # => true/false

# Get all adapters (convenience method)
SimpleBLE.adapters            # => [Adapter, ...]

# Quick scan with first available adapter
SimpleBLE.scan(timeout_ms)    # => [Peripheral, ...]
```

### Adapter Management

```ruby
# Get all available Bluetooth adapters
adapters = SimpleBLE::Adapter.get_adapters
adapter = adapters.first

# Adapter information
adapter.identifier            # => "Default Adapter [uuid]"  
adapter.address              # => "XX:XX:XX:XX:XX:XX" (or UUID on macOS)

# Scanning operations
adapter.scan_start           # Start continuous scan
adapter.scan_stop            # Stop scanning
adapter.scan_for(timeout_ms) # Scan for specific duration
adapter.scan_active?         # => true/false
adapter.scan_results         # => [Peripheral, ...]
```

### Peripheral Information

```ruby
devices = SimpleBLE.scan(5000)
device = devices.first

device.identifier            # Device name or identifier
device.address              # MAC address or UUID  
device.rssi                 # Signal strength
device.address_type         # Address type (public/random)
device.connectable?         # Whether device accepts connections
device.connected?           # Current connection status
```

## 🧪 Interactive Testing

Launch an interactive Ruby session with SimpleBLE loaded:

```bash
ruby -rsimpleble -e "
adapters = SimpleBLE.adapters
adapter = adapters.first
puts 'Try: SimpleBLE.scan(3000)'
require 'irb'; IRB.start
"
```

## 🔧 Development

### Building from Source

```bash
# Clone repository with submodules
git clone --recurse-submodules https://github.com/twilightcoders/ruby-simpleble.git
cd ruby-simpleble

# Or if you already cloned without submodules:
git submodule update --init --recursive

# Install dependencies
bundle install

# Compile the C extension 
rake compile

# Run tests
rake test
```

### Updating SimpleBLE Vendor Library

```bash
# Update to latest SimpleBLE upstream
git submodule update --remote vendor/simpleble

# Verify the update
git submodule status
```

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run with coverage
bundle exec rspec --format documentation

# Test specific functionality  
bundle exec rspec spec/simpleble_spec.rb
```

## 🏗️ Architecture

SimpleBLE Ruby uses a layered architecture:

```
Ruby Application
       ↓
SimpleBLE Ruby Wrapper (lib/simpleble.rb)
       ↓  
C Extension Layer (ext/simpleble/)
       ↓
SimpleBLE C++ Library (vendor/simpleble/)
       ↓
Platform BLE APIs (CoreBluetooth/BlueZ/WinRT)
```

### Key Components

- **Ruby API Layer**: Clean, idiomatic Ruby interface
- **C Extension**: Memory-safe Ruby ↔ C++ bridge  
- **C++ Wrapper**: Type-safe interface to SimpleBLE library
- **SimpleBLE Library**: Cross-platform BLE abstraction
- **Platform Backends**: OS-specific BLE implementations

## 🚦 Current Status

### ✅ **Completed** 
- Cross-platform build system and C extension compilation
- Bluetooth adapter discovery and management
- BLE device scanning with timeout control
- Memory-safe Ruby object lifecycle management
- Comprehensive test suite and documentation

### 🚧 **In Development**
- GATT service and characteristic operations
- Device connection and disconnection
- Read/write/notify operations for characteristics  
- Advanced BLE features (bonding, security, callbacks)

### 🔮 **Planned**
- Asynchronous operation support with Ruby blocks
- Device filtering and advanced scanning options
- Cross-platform CI/CD pipeline
- Performance optimization and memory profiling

## 📊 Compatibility

| Platform | Status | Backend | Notes |
|----------|---------|---------|-------|
| **macOS** | ✅ Working | CoreBluetooth | Full support, tested |
| **Linux** | 🚧 Ready | BlueZ/DBus | Build system ready, needs testing |
| **Windows** | 🚧 Ready | WinRT | Build system ready, needs testing |

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Run tests: `bundle exec rspec`
4. Commit your changes (`git commit -am 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.

## 🙏 Acknowledgments

- [SimpleBLE Library](https://github.com/OpenBluetoothToolbox/SimpleBLE) - The excellent cross-platform BLE library this gem wraps
- [OpenBluetoothToolbox](https://github.com/OpenBluetoothToolbox) - For creating and maintaining SimpleBLE

## 🔗 Links

- [Homepage](https://github.com/twilightcoders/ruby-simpleble)
- [Documentation](https://github.com/twilightcoders/ruby-simpleble)
- [Issue Tracker](https://github.com/twilightcoders/ruby-simpleble/issues) 
- [SimpleBLE Library](https://github.com/OpenBluetoothToolbox/SimpleBLE)
