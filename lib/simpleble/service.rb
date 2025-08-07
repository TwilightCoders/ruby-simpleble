module SimpleBLE
  class Service
    # Instance methods (implemented in C extension)
    def uuid
      # Returns the service UUID
    end

    def data
      # Returns the service data
    end

    def characteristics
      # Returns array of characteristics for this service
    end
  end
end