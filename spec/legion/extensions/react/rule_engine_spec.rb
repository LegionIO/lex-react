# frozen_string_literal: true

require 'legion/extensions/react/rule_engine'

RSpec.describe Legion::Extensions::React::RuleEngine do
  let(:rules_config) do
    {
      ci_failure: {
        enabled:   true,
        source:    'github.check_run.completed',
        condition: "conclusion == 'failure'",
        autonomy:  'filter',
        chain:     ['lex-github.runners.fetch_check_logs']
      },
      review_comment: {
        enabled:   true,
        source:    'github.pull_request_review_comment',
        autonomy:  'observe',
        chain:     ['lex-github.runners.fetch_comment']
      },
      disabled_rule: {
        enabled:   false,
        source:    'tfe.*',
        autonomy:  'filter',
        chain:     ['lex-tfe.runners.check']
      }
    }
  end

  subject(:engine) { described_class.new(rules_config) }

  describe '#rules' do
    it 'loads only enabled rules' do
      expect(engine.rules.size).to eq(2)
    end

    it 'parses rule attributes' do
      rule = engine.rules.find { |r| r[:id] == :ci_failure }
      expect(rule[:source]).to eq('github.check_run.completed')
      expect(rule[:autonomy]).to eq(:filter)
      expect(rule[:chain]).to eq(['lex-github.runners.fetch_check_logs'])
    end
  end

  describe '#match' do
    it 'returns matching rules for an event' do
      event = { event: 'github.check_run.completed', conclusion: 'failure' }
      matches = engine.match(event)
      expect(matches.size).to eq(1)
      expect(matches.first[:id]).to eq(:ci_failure)
    end

    it 'returns empty when event matches pattern but condition fails' do
      event = { event: 'github.check_run.completed', conclusion: 'success' }
      matches = engine.match(event)
      expect(matches).to be_empty
    end

    it 'returns matching rules without conditions' do
      event = { event: 'github.pull_request_review_comment' }
      matches = engine.match(event)
      expect(matches.size).to eq(1)
      expect(matches.first[:id]).to eq(:review_comment)
    end

    it 'returns empty for non-matching events' do
      event = { event: 'consul.health.critical' }
      matches = engine.match(event)
      expect(matches).to be_empty
    end
  end

  describe '.from_settings' do
    before do
      Legion::Settings.set_test_data({ react: { rules: rules_config } })
    end

    it 'loads rules from Settings' do
      engine = described_class.from_settings
      expect(engine.rules.size).to eq(2)
    end

    it 'returns empty engine when no settings' do
      Legion::Settings.set_test_data({})
      engine = described_class.from_settings
      expect(engine.rules).to be_empty
    end
  end
end
