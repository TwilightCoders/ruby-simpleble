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
- ✅ Adapter discovery & identifiers
- ✅ Bluetooth enabled check  
- ✅ Device scanning (blocking scan_for + continuous start/stop)
- ✅ Peripheral information (identifier, address, RSSI, TX power, MTU, address_type)
- ✅ Connection lifecycle (connect, disconnect, paired?, unpair)
- ✅ Paired peripherals access
- ✅ GATT service & characteristic enumeration with capabilities
- ✅ Characteristic read/write operations (request & command modes)
- ✅ Descriptor read/write operations
- ✅ Manufacturer data & advertisement parsing
- 🚧 Notifications/Indications *(callback support planned)*

### 🏗️ **Current State**
- ✅ Core C extension foundation & memory management for adapters/peripherals
- ✅ Exception hierarchy & native error mapping (scan/connection/characteristic errors)
- ✅ Cross-platform build scripts (macOS/Linux/Windows all working)
- ✅ Comprehensive adapter & peripheral API implemented
- ✅ GATT operations layer with service/characteristic/descriptor access
- ✅ Ruby-friendly API with helper methods and convenience features
- 🚧 Expanded test coverage (integration tests gated by hardware)
- 🚧 Notification/indication callback support

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
adapter.paired_peripherals   # => [Peripheral, ...] - Previously paired devices
```

### Peripheral Operations

```ruby
devices = SimpleBLE.scan(5000)
device = devices.first

# Basic information
device.identifier            # Device name or identifier
device.address              # MAC address or UUID  
device.rssi                 # Signal strength in dBm
device.tx_power             # Advertised TX power in dBm
device.mtu                  # Maximum transmission unit
device.address_type         # Address type (public/random/unspecified)

# Connection management
device.connectable?         # Whether device accepts connections
device.connected?           # Current connection status
device.paired?              # Whether device is paired
device.connect              # Establish connection
device.disconnect           # Close connection
device.unpair               # Remove pairing

# GATT operations (requires connection)
services = device.services  # => [{"uuid" => "...", "characteristics" => [...]}]
data = device.read_characteristic(service_uuid, char_uuid)
device.write_characteristic_request(service_uuid, char_uuid, data)
device.write_characteristic_command(service_uuid, char_uuid, data)

# Descriptor operations
desc_data = device.read_descriptor(service_uuid, char_uuid, desc_uuid)
device.write_descriptor(service_uuid, char_uuid, desc_uuid, data)

# Advertisement data
mfg_data = device.manufacturer_data  # => [{"manufacturer_id" => 123, "data" => "..."}]

# Helper methods
device.name                 # Friendly name (identifier or address)
device.to_s                 # "Name (address)"
device.has_data?            # Check if device has valid data
device.rssi_s               # "-67 dBm"
device.address_type_s       # "Public" / "Random" / "Unspecified"
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

### 🚦 Status Summary

| Area | Implemented | Notes |
|------|-------------|-------|
| Adapter enumeration | ✅ | identifier, address |
| Scanning (start/stop/for) | ✅ | Timed & continuous |
| Scan results retrieval | ✅ | Returns Peripheral objects |
| Peripheral basic info | ✅ | identifier, address, RSSI, TX power, MTU, address_type |
| Connection lifecycle | ✅ | connect, disconnect, paired?, unpair |
| Paired peripherals | ✅ | Access to previously paired devices |
| Services/Characteristics | ✅ | Full enumeration with capabilities |
| Characteristic I/O | ✅ | Read/write with request & command modes |
| Descriptor I/O | ✅ | Read/write operations |
| Manufacturer data | ✅ | Advertisement parsing |
| Windows support | ✅ | All platforms working |
| Test coverage | 🚧 | Expanding beyond placeholders |
| Documentation accuracy | ✅ | Reflects current API |

### Roadmap
- [ ] Notification/indication callbacks with GC-safe storage
- [ ] Hardware-gated integration test suite expansion
- [ ] Performance optimizations and memory usage analysis
- [ ] Precompiled native gem variants (later)

## 📊 Compatibility

| Platform | Status | Backend | Notes |
|----------|---------|---------|-------|
| **macOS** | ✅ Working | CoreBluetooth | Full support, production tested |
| **Linux** | ✅ Working | BlueZ/DBus | CI passing, production ready |
| **Windows** | ✅ Working | WinRT | CI passing, production ready |

## ⚡ CI Performance & Caching

Building the SimpleBLE core for every Ruby version slows the matrix. Two knobs:

1. `SIMPLEBLE_PREBUILT_LIB` – point to a prebuilt static library (and headers) so only the Ruby bridge compiles.
2. `SIMPLEBLE_REUSE_OBJECTS=1` – skip `make clean` and reuse previously cached `.o` files.

### Prebuilt Flow
Create a warmup job that builds once, packages `tmp_flat/*.o` (or a consolidated `libsimpleble_core.a` you produce via `ar`), uploads as an artifact, then matrix jobs download and set:
```
env:
       SIMPLEBLE_PREBUILT_LIB: path/to/libsimpleble_core.a
```
`extconf.rb` detects this and links only the Ruby layer.

### Object Reuse Flow
Use `actions/cache` keyed on OS + hash of `vendor/simpleble/**`:
```
- uses: actions/cache@v4
       with:
              path: ext/simpleble/tmp_flat
              key: simpleble-obj-${{ runner.os }}-${{ hashFiles('vendor/simpleble/**') }}
```
Then set `SIMPLEBLE_REUSE_OBJECTS: 1` so the compile task skips cleaning.

### Variables Summary
| Var | Purpose |
|-----|---------|
| `SIMPLEBLE_PREBUILT_LIB` | Path to prebuilt SimpleBLE static lib to link instead of compiling sources |
| `SIMPLEBLE_REUSE_OBJECTS` | If `1`, do not run `make clean`; rely on cached object files |

Regenerate caches whenever the SimpleBLE submodule changes.

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
