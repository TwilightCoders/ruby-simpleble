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
  describe "adapter management", :integration do
    it "can get list of available adapters" do
      skip "C extension not yet linked with SimpleBLE library"
      adapters = SimpleBLE::Adapter.get_adapters
      expect(adapters).to be_an(Array)
    end

    it "can check bluetooth status" do
      skip "C extension not yet linked with SimpleBLE library"
      status = SimpleBLE::Adapter.bluetooth_enabled?
      expect(status).to be_in([true, false])
    end
  end

  describe "instance methods", :integration do
    let(:adapter) { SimpleBLE::Adapter.get_adapters.first }

    before do
      skip "C extension not yet linked with SimpleBLE library"
    end

    it "has an identifier" do
      expect(adapter.identifier).to be_a(String)
      expect(adapter.identifier).not_to be_empty
    end

    it "has an address" do
      expect(adapter.address).to be_a(String)
      expect(adapter.address).to match(/\A[0-9A-Fa-f:]{17}\z/) # MAC address format
    end

    it "can start and stop scanning" do
      expect { adapter.scan_start }.not_to raise_error
      expect { adapter.scan_stop }.not_to raise_error
    end

    it "can scan for a specific duration" do
      expect { adapter.scan_for(1000) }.not_to raise_error
    end

    it "can check if scan is active" do
      scan_active = adapter.scan_is_active?
      expect(scan_active).to be_in([true, false])
    end

    it "can get scan results" do
      adapter.scan_for(1000)
      results = adapter.scan_results
      expect(results).to be_an(Array)
    end
  end
end