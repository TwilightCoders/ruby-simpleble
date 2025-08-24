#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'simpleble'
require 'benchmark'

def run_benchmarks
  puts "# SimpleBLE Benchmarks"
  puts
  puts "Platform: #{RUBY_PLATFORM}"
  puts "Ruby Version: #{RUBY_VERSION}"
  puts "SimpleBLE Version: #{SimpleBLE::VERSION}"
  puts

  unless SimpleBLE.bluetooth_enabled?
    puts "❌ Bluetooth not available on this system"
    return
  end

  adapters = SimpleBLE.adapters
  if adapters.empty?
    puts "❌ No Bluetooth adapters found"
    return
  end

  adapter = adapters.first
  puts "Using adapter: #{adapter.identifier}"
  puts

  # Benchmark different scan durations
  scan_durations = [1000, 3000, 5000, 10000] # milliseconds

  puts "## Scan Performance Benchmarks"
  puts
  puts "| Duration | Devices Found | Scan Time | Avg Device Discovery |"
  puts "|----------|---------------|-----------|---------------------|"

  scan_durations.each do |duration|
    scan_time = Benchmark.realtime do
      adapter.scan_for(duration)
    end

    devices = adapter.scan_results
    device_count = devices.length
    avg_discovery_time = device_count > 0 ? (scan_time * 1000 / device_count).round(1) : 0

    puts "| #{duration}ms | #{device_count} | #{(scan_time * 1000).round(1)}ms | #{avg_discovery_time}ms/device |"
  end

  puts
  puts "## Memory Usage Test"
  puts

  initial_memory = `ps -o rss= -p #{Process.pid}`.to_i

  puts "Running 50 scan cycles (3 second scans)..."
  50.times do |i|
    adapter.scan_for(3000)
    results = adapter.scan_results
    print "." if i % 10 == 0
  end
  puts

  final_memory = `ps -o rss= -p #{Process.pid}`.to_i
  memory_diff = final_memory - initial_memory

  puts "- Initial memory: #{initial_memory} KB"
  puts "- Final memory: #{final_memory} KB"
  puts "- Memory difference: #{memory_diff} KB"
  puts "- Result: #{memory_diff.abs < 5000 ? '✅ No significant memory leak' : '⚠️ Potential memory increase'}"
  puts

  puts "## Test Environment"
  puts
  puts "- **Platform**: #{RUBY_PLATFORM}"
  puts "- **Ruby Version**: #{RUBY_VERSION}"
  puts "- **Architecture**: #{RbConfig::CONFIG['host_cpu']}"
  puts "- **Compiler**: #{RbConfig::CONFIG['CC']}"
  puts "- **OS**: #{RbConfig::CONFIG['host_os']}"
  puts "- **Bluetooth Status**: #{SimpleBLE.bluetooth_enabled? ? '✅ Enabled' : '❌ Disabled'}"
  puts "- **Available Adapters**: #{SimpleBLE.adapters.length}"
  puts
  puts "*Note: Results may vary based on BLE environment and system load.*"
end

if __FILE__ == $0
  puts "Running SimpleBLE Benchmarks..."
  puts "=" * 50
  puts
  run_benchmarks
end
