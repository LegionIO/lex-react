# frozen_string_literal: true

require 'legion/extensions/react/helpers/event_matcher'

RSpec.describe Legion::Extensions::React::Helpers::EventMatcher do
  describe '.match?' do
    it 'matches exact event names' do
      expect(described_class.match?('github.push', 'github.push')).to be true
    end

    it 'matches wildcard patterns' do
      expect(described_class.match?('github.*', 'github.push')).to be true
      expect(described_class.match?('github.*', 'github.check_run.completed')).to be false
    end

    it 'matches double-wildcard patterns' do
      expect(described_class.match?('github.**', 'github.check_run.completed')).to be true
    end

    it 'rejects non-matching patterns' do
      expect(described_class.match?('tfe.*', 'github.push')).to be false
    end

    it 'matches star-only wildcard' do
      expect(described_class.match?('*', 'anything')).to be true
    end
  end

  describe '.evaluate_condition' do
    let(:event) { { event: 'github.check_run.completed', conclusion: 'failure', status: 'completed' } }

    it 'returns true when condition matches' do
      expect(described_class.evaluate_condition("conclusion == 'failure'", event)).to be true
    end

    it 'returns false when condition does not match' do
      expect(described_class.evaluate_condition("conclusion == 'success'", event)).to be false
    end

    it 'returns true when condition is nil' do
      expect(described_class.evaluate_condition(nil, event)).to be true
    end

    it 'returns true when condition is empty' do
      expect(described_class.evaluate_condition('', event)).to be true
    end

    it 'returns false on unparseable condition' do
      expect(described_class.evaluate_condition('invalid!!!', event)).to be false
    end
  end
end
