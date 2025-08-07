# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2025-01-25

### Added

- Initial release of ruby-simpleble gem
- Ruby C extension bindings for SimpleBLE C++ library
- Cross-platform Bluetooth Low Energy (BLE) support
  - macOS: CoreBluetooth framework integration
  - Linux: DBus/BlueZ backend support (ready for testing)
  - Windows: WinRT Bluetooth APIs (ready for testing)
- Bluetooth adapter discovery and management
- BLE device scanning with timeout control
- Real-time device discovery with proper device enumeration
- Memory-safe Ruby object lifecycle management
- Comprehensive exception hierarchy for error handling
- Module-level convenience methods: `SimpleBLE.bluetooth_enabled?`, `SimpleBLE.adapters`, `SimpleBLE.scan`
- Object-oriented API with Adapter, Peripheral, Service, Characteristic, and Descriptor classes
- Cross-platform build system with automatic dependency detection
- Comprehensive RSpec test suite with integration test support
- Performance benchmarking tools
- Docker-based multi-platform testing
- Complete API documentation with usage examples

### Technical Implementation

- C++ wrapper bridge for SimpleBLE C++ library integration
- Platform-specific compilation flags and framework linking
- Vendor SimpleBLE library compilation with CMake integration
- Thread-safe operations with proper resource cleanup
- Opaque handle management for BLE resources
- Cross-platform CI/CD pipeline with GitHub Actions
- Quality assurance with Qlty integration

### Supported Operations

- Bluetooth adapter enumeration and identification
- BLE device scanning (working, tested with real devices)
- Device information access (identifier, address, RSSI)
- Scan result management and filtering
- Connection status monitoring

### Development Tools

- Cross-platform build configuration (`extconf.rb`)
- Comprehensive test suite with smart integration test skipping
- Performance benchmarking with memory leak detection
- Docker-based testing for multiple Ruby versions
- GitHub Actions CI/CD with cross-platform matrix testing