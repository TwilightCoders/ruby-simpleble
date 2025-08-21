module SimpleBLE
  # Base exception for all SimpleBLE errors
  class Error < StandardError; end

  # Raised when a feature is not supported on the current platform
  class NotSupportedError < Error; end

  # Raised when Bluetooth is not available or disabled
  class BluetoothNotAvailableError < Error; end

  # Raised when attempting operations on disconnected peripherals
  class NotConnectedError < Error; end

  # Raised when connection to peripheral fails
  class ConnectionError < Error; end

  # Raised when scan operations fail
  class ScanError < Error; end

  # Raised when characteristic/service operations fail
  class CharacteristicError < Error; end

  # Raised when timeout occurs during operations
  class TimeoutError < Error; end
end
