# frozen_string_literal: true

require 'legion/extensions/react/reaction_dispatcher'

RSpec.describe Legion::Extensions::React::ReactionDispatcher do
  let(:loop_breaker) { Legion::Extensions::React::Helpers::LoopBreaker.new(max_depth: 3, cooldown_seconds: 60, max_per_hour: 100) }
  subject(:dispatcher) { described_class.new(loop_breaker: loop_breaker) }

  let(:event) { { event: 'github.check_run.completed', conclusion: 'failure', timestamp: Time.now } }

  describe '#dispatch' do
    it 'logs and returns :observed for OBSERVE rules' do
      rule = { id: :ci_failure, autonomy: :observe, chain: ['lex-github.runners.fetch_logs'] }
      result = dispatcher.dispatch(rule: rule, event: event, depth: 0)
      expect(result[:success]).to be true
      expect(result[:action]).to eq(:observed)
    end

    it 'dispatches chain for FILTER rules' do
      rule = { id: :ci_failure, autonomy: :filter, chain: ['lex-github.runners.fetch_logs'] }
      result = dispatcher.dispatch(rule: rule, event: event, depth: 0)
      expect(result[:success]).to be true
      expect(result[:action]).to eq(:dispatched)
      expect(result[:chain]).to eq(['lex-github.runners.fetch_logs'])
    end

    it 'blocks when loop breaker denies' do
      rule = { id: :ci_failure, autonomy: :filter, chain: ['lex-github.runners.fetch_logs'] }
      allow(loop_breaker).to receive(:allow?).and_return(false)
      result = dispatcher.dispatch(rule: rule, event: event, depth: 0)
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:loop_blocked)
    end

    it 'records in loop breaker after dispatch' do
      rule = { id: :ci_failure, autonomy: :filter, chain: ['lex-github.runners.fetch_logs'] }
      dispatcher.dispatch(rule: rule, event: event, depth: 0)
      expect(loop_breaker.reactions_this_hour).to eq(1)
    end

    it 'dispatches for TRANSFORM rules' do
      rule = { id: :ci_failure, autonomy: :transform, chain: ['lex-transformer.runners.analyze'] }
      result = dispatcher.dispatch(rule: rule, event: event, depth: 0)
      expect(result[:action]).to eq(:dispatched)
    end

    it 'dispatches for AUTONOMOUS rules' do
      rule = { id: :ci_failure, autonomy: :autonomous, chain: ['lex-github.runners.auto_fix'] }
      result = dispatcher.dispatch(rule: rule, event: event, depth: 0)
      expect(result[:action]).to eq(:dispatched)
    end
  end
end
