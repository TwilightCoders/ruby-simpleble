require 'spec_helper'

RSpec.describe SimpleBLE do
  describe "module constants" do
    it "has a version" do
      expect(SimpleBLE::VERSION).not_to be_nil
      expect(SimpleBLE::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
    end
  end

  describe "module methods" do
    it "responds to adapters method" do
      expect(SimpleBLE).to respond_to(:adapters)
    end

    it "responds to bluetooth_enabled? method" do
      expect(SimpleBLE).to respond_to(:bluetooth_enabled?)
    end

    it "responds to scan method" do
      expect(SimpleBLE).to respond_to(:scan)
    end
  end

  describe "exception hierarchy" do
    it "defines base Error class" do
      expect(defined?(SimpleBLE::Error)).not_to be_nil
      expect(SimpleBLE::Error).to be < StandardError
    end

    it "defines specific error classes" do
      expect(defined?(SimpleBLE::BluetoothNotAvailableError)).not_to be_nil
      expect(defined?(SimpleBLE::ConnectionError)).not_to be_nil
      expect(defined?(SimpleBLE::ScanError)).not_to be_nil
      expect(defined?(SimpleBLE::CharacteristicError)).not_to be_nil
    end
  end

  describe "class definitions" do
    it "defines core BLE classes" do
      expect(defined?(SimpleBLE::Adapter)).not_to be_nil
      expect(defined?(SimpleBLE::Peripheral)).not_to be_nil
      expect(defined?(SimpleBLE::Service)).not_to be_nil
      expect(defined?(SimpleBLE::Characteristic)).not_to be_nil
      expect(defined?(SimpleBLE::Descriptor)).not_to be_nil
    end
  end

  # Note: The following tests will fail until the C extension is properly compiled
  # and linked with SimpleBLE library. They're included for future development.

  describe "adapter functionality", :integration do
    it "can check if bluetooth is enabled" do
      expect { SimpleBLE.bluetooth_enabled? }.not_to raise_error
      expect([true, false]).to include(SimpleBLE.bluetooth_enabled?)
    end

    it "can get available adapters" do
      skip "C extension not yet linked with SimpleBLE library"
      expect { SimpleBLE.adapters }.not_to raise_error
    end
  end

  describe "scanning functionality", :integration do
    it "can perform a basic scan" do
      skip "C extension not yet linked with SimpleBLE library"
      expect { SimpleBLE.scan(1000) }.not_to raise_error
    end
  end
end