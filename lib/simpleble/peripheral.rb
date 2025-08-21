module SimpleBLE
  class Peripheral
    # All core methods are implemented in the C extension.
    # This Ruby file provides additional helper methods.

    # Returns the peripheral name (identifier with fallback to address)
    def name
      id = identifier
      (id.nil? || id.empty?) ? address : id
    end

    # Returns a summary string for the peripheral
    def to_s
      "#{name} (#{address})"
    end

    # Convenience method for write operations - uses write_request by default
    def write_characteristic(service_uuid, char_uuid, data)
      write_characteristic_request(service_uuid, char_uuid, data)
    end

    # Helper to get service by UUID
    def service(uuid)
      services.find { |s| s['uuid'] == uuid }
    end

    # Helper to get characteristic by service and characteristic UUID
    def characteristic(service_uuid, char_uuid)
      svc = service(service_uuid)
      return nil unless svc

      svc['characteristics'].find { |c| c['uuid'] == char_uuid }
    end

    # Helper to check if peripheral has data (not empty identifiers)
    def has_data?
      !identifier.nil? && !identifier.empty? && !address.nil? && !address.empty?
    end

    # Format RSSI with units
    def rssi_s
      "#{rssi} dBm"
    end

    # Format TX power with units
    def tx_power_s
      "#{tx_power} dBm"
    end

    # Format MTU with units
    def mtu_s
      "#{mtu} bytes"
    end

    # Human readable address type
    def address_type_s
      case address_type
      when 0 then "Public"
      when 1 then "Random"
      when 2 then "Unspecified"
      else "Unknown (#{address_type})"
      end
    end
  end
end
