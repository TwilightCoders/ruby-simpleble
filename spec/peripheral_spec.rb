require 'spec_helper'

RSpec.describe SimpleBLE::Peripheral do
  describe "instance methods", :integration do
    let(:adapter) { SimpleBLE::Adapter.get_adapters.first }
    let(:peripheral) do
      adapter.scan_for(5000)
      adapter.scan_results.first
    end

    before do
      skip "C extension not yet linked with SimpleBLE library"
      skip "No peripherals found" unless peripheral
    end

    it "has an identifier" do
      expect(peripheral.identifier).to be_a(String)
    end

    it "has an address" do
      expect(peripheral.address).to be_a(String)
      expect(peripheral.address).to match(/\A[0-9A-Fa-f:]{17}\z/) # MAC address format
    end

    it "has an address type" do
      address_type = peripheral.address_type
      expect(address_type).to be_an(Integer)
      expect(address_type).to be >= 0
    end

    it "has an RSSI value" do
      rssi = peripheral.rssi
      expect(rssi).to be_an(Integer)
      expect(rssi).to be <= 0 # RSSI is typically negative
    end

    it "can check connection status" do
      connected = peripheral.connected?
      expect(connected).to be_in([true, false])
    end

    it "can check if connectable" do
      connectable = peripheral.connectable?
      expect(connectable).to be_in([true, false])
    end

    it "can connect and disconnect" do
      skip "Skipping connection test to avoid interfering with devices"
      
      expect { peripheral.connect }.not_to raise_error
      expect(peripheral.connected?).to be true
      
      expect { peripheral.disconnect }.not_to raise_error
      expect(peripheral.connected?).to be false
    end

    it "can get services when connected" do
      skip "Requires connection to device"
      
      peripheral.connect
      services = peripheral.services
      expect(services).to be_an(Array)
      services.each do |service|
        expect(service).to be_a(SimpleBLE::Service)
      end
    end
  end
end