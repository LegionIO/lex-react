# frozen_string_literal: true

require 'legion/extensions/react/runners/react'

RSpec.describe Legion::Extensions::React::Runners::React do
  before do
    Legion::Settings.set_test_data({
                                     react: {
                                       rules:                  {
                                         ci_failure: {
                                           enabled:   true,
                                           source:    'github.check_run.completed',
                                           condition: "conclusion == 'failure'",
                                           autonomy:  'filter',
                                           chain:     ['lex-github.runners.fetch_check_logs']
                                         },
                                         all_events: {
                                           enabled:  true,
                                           source:   'github.**',
                                           autonomy: 'observe',
                                           chain:    ['lex-log.runners.output']
                                         }
                                       },
                                       max_depth:              3,
                                       cooldown_seconds:       60,
                                       max_reactions_per_hour: 100
                                     }
                                   })
    described_class.reset!
  end

  describe '.handle_event' do
    it 'processes a matching event' do
      result = described_class.handle_event(
        event: { event: 'github.check_run.completed', conclusion: 'failure', timestamp: Time.now }
      )
      expect(result[:success]).to be true
      expect(result[:matched_rules]).to be >= 1
    end

    it 'returns zero matches for unmatched events' do
      result = described_class.handle_event(
        event: { event: 'consul.health.passing', timestamp: Time.now }
      )
      expect(result[:success]).to be true
      expect(result[:matched_rules]).to eq(0)
    end
  end

  describe '.react_stats' do
    it 'returns stats' do
      stats = described_class.react_stats
      expect(stats[:success]).to be true
      expect(stats[:rule_count]).to eq(2)
      expect(stats).to have_key(:reactions_this_hour)
    end
  end
end
