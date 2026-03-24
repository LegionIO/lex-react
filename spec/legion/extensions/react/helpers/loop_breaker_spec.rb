# frozen_string_literal: true

require 'legion/extensions/react/helpers/loop_breaker'

RSpec.describe Legion::Extensions::React::Helpers::LoopBreaker do
  subject(:breaker) { described_class.new(max_depth: 3, cooldown_seconds: 60, max_per_hour: 100) }

  describe '#allow?' do
    it 'allows a reaction at depth 0' do
      expect(breaker.allow?(rule_id: 'ci_failure', depth: 0)).to be true
    end

    it 'blocks a reaction exceeding max_depth' do
      expect(breaker.allow?(rule_id: 'ci_failure', depth: 4)).to be false
    end

    it 'blocks a duplicate rule within cooldown' do
      breaker.record(rule_id: 'ci_failure', event_id: 'evt-1')
      expect(breaker.allow?(rule_id: 'ci_failure', depth: 0, event_id: 'evt-1')).to be false
    end

    it 'allows same rule for different event_id' do
      breaker.record(rule_id: 'ci_failure', event_id: 'evt-1')
      expect(breaker.allow?(rule_id: 'ci_failure', depth: 0, event_id: 'evt-2')).to be true
    end

    it 'blocks when hourly limit is exceeded' do
      small_breaker = described_class.new(max_depth: 10, cooldown_seconds: 0, max_per_hour: 2)
      small_breaker.record(rule_id: 'a', event_id: '1')
      small_breaker.record(rule_id: 'b', event_id: '2')
      expect(small_breaker.allow?(rule_id: 'c', depth: 0)).to be false
    end
  end

  describe '#record' do
    it 'increments reaction count' do
      expect { breaker.record(rule_id: 'x', event_id: 'e1') }
        .to change { breaker.reactions_this_hour }.by(1)
    end
  end

  describe '#stats' do
    it 'returns reaction stats' do
      breaker.record(rule_id: 'a', event_id: '1')
      stats = breaker.stats
      expect(stats[:reactions_this_hour]).to eq(1)
      expect(stats[:max_per_hour]).to eq(100)
    end
  end
end
