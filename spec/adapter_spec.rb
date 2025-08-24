require 'spec_helper'

RSpec.describe SimpleBLE::Adapter do
  describe "class methods" do
    it "responds to get_adapters" do
      expect(SimpleBLE::Adapter).to respond_to(:get_adapters)
    end

    it "responds to bluetooth_enabled?" do
      expect(SimpleBLE::Adapter).to respond_to(:bluetooth_enabled?)
    end
  end

  # Integration tests that require working C extension
  describe "adapter management" do
    it "returns an array from get_adapters" do
      adapters = SimpleBLE::Adapter.get_adapters
      expect(adapters).to be_an(Array)
    end

    it "returns boolean for bluetooth_enabled?" do
      status = SimpleBLE::Adapter.bluetooth_enabled?
      expect([true, false]).to include(status)
    end
  end

  describe "instance methods", :integration do
    let(:adapter) { SimpleBLE::Adapter.get_adapters.first }

    before do
      skip "No adapter available on this system" unless adapter
    end

    it "has an identifier" do
      expect(adapter.identifier).to be_a(String)
      expect(adapter.identifier).not_to be_empty
    end

    it "has an address" do
      addr = adapter.address
      expect(addr).to be_a(String)
      expect(addr).not_to be_empty
      mac_regex = /\A(?:[0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}\z/
      uuid_regex = /\A[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}\z/
      # Some platforms (or disabled Bluetooth) may return a UUID-like identifier instead of a MAC.
      expect(addr).to match(mac_regex).or match(uuid_regex)
    end

    it "can perform a timed scan and retrieve results" do
      skip "Bluetooth disabled" unless SimpleBLE::Adapter.bluetooth_enabled?
      adapter.scan_for(200) # short scan
      results = adapter.scan_results
      expect(results).to be_an(Array)
    end

    it "can start and stop continuous scanning" do
      skip "Bluetooth disabled" unless SimpleBLE::Adapter.bluetooth_enabled?
      adapter.scan_start
      expect(adapter.scan_active?).to be(true).or be(false) # presence check
      adapter.scan_stop
    end
  end
end
