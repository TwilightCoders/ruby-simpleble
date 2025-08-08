require 'spec_helper'

RSpec.describe 'SimpleBLE Windows extension presence' do
  it 'lists extension directory contents for diagnostics' do
    skip 'Not Windows' unless Gem.win_platform?
    dir = File.expand_path('../../lib/simpleble', __dir__)
    files = Dir.glob(File.join(dir, '*')).map { |f| File.basename(f) }
    puts "[diagnostic] lib/simpleble contents: #{files.join(', ')}"
    so = Dir.glob(File.join(dir, 'simpleble.{so,bundle,dll}')).first
    expect(so).not_to be_nil
  end
end
