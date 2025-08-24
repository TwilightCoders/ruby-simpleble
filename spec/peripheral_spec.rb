require 'spec_helper'

RSpec.describe SimpleBLE::Peripheral do
  describe "instance methods" do
    let(:adapter) { SimpleBLE::Adapter.get_adapters.first }
    let(:peripheral) do
      if adapter
        adapter.scan_for(300)
        adapter.scan_results.first
      end
    end

    before do
      skip "No adapter available" unless adapter
      skip "No peripherals discovered in short scan" unless peripheral
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
    end

    it "has an RSSI value" do
      rssi = peripheral.rssi
      expect(rssi).to be_an(Integer)
    end

    it "can check connection status" do
      expect([true, false]).to include(peripheral.connected?)
    end

    it "can check if connectable" do
      expect([true, false]).to include(peripheral.connectable?)
    end

    it "can attempt connect and disconnect (may be no-op)" do
      # Not all devices allow connection; ensure no exceptions
      begin
        peripheral.connect
        peripheral.disconnect
      rescue SimpleBLE::ConnectionError
        # Acceptable if device rejects connection
      end
    end

    # services pending implementation
  end
end
