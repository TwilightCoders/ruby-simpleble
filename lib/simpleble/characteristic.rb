module SimpleBLE
  class Characteristic
    # Instance methods (implemented in C extension)
    def uuid
      # Returns the characteristic UUID
    end

    def capabilities
      # Returns array of capability strings (read, write, notify, indicate, etc.)
    end

    def descriptors
      # Returns array of descriptors for this characteristic
    end

    def can_read?
      capabilities.include?('read')
    end

    def can_write?
      capabilities.include?('write')
    end

    def can_write_without_response?
      capabilities.include?('write-without-response')
    end

    def can_notify?
      capabilities.include?('notify')
    end

    def can_indicate?
      capabilities.include?('indicate')
    end
  end
end