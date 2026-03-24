# frozen_string_literal: true

require 'legion/extensions/react/helpers/constants'

RSpec.describe Legion::Extensions::React::Helpers::Constants do
  it 'defines AUTONOMY_LEVELS' do
    expect(described_class::AUTONOMY_LEVELS).to include(:observe, :filter, :transform, :autonomous)
  end

  it 'defines DEFAULT_MAX_DEPTH' do
    expect(described_class::DEFAULT_MAX_DEPTH).to eq(3)
  end

  it 'defines DEFAULT_COOLDOWN_SECONDS' do
    expect(described_class::DEFAULT_COOLDOWN_SECONDS).to eq(60)
  end

  it 'defines DEFAULT_MAX_REACTIONS_PER_HOUR' do
    expect(described_class::DEFAULT_MAX_REACTIONS_PER_HOUR).to eq(100)
  end

  it 'defines AUTONOMY_THRESHOLDS' do
    expect(described_class::AUTONOMY_THRESHOLDS[:filter]).to eq(0.3)
    expect(described_class::AUTONOMY_THRESHOLDS[:transform]).to eq(0.6)
    expect(described_class::AUTONOMY_THRESHOLDS[:autonomous]).to eq(0.8)
  end
end
