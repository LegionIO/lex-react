# frozen_string_literal: true

RSpec.describe 'EventSubscriber' do
  describe 'Legion::Extensions::React.subscribe!' do
    before do
      Legion::Events.clear
      Legion::Settings.set_test_data({
        react: {
          rules: {
            test_rule: {
              enabled:  true,
              source:   'test.event',
              autonomy: 'observe',
              chain:    ['test.runner']
            }
          }
        }
      })
      Legion::Extensions::React::Runners::React.reset!
    end

    it 'subscribes to all events' do
      Legion::Extensions::React.subscribe!
      expect(Legion::Events.listener_count('*')).to be >= 1
    end

    it 'processes events through the reaction engine' do
      Legion::Extensions::React.subscribe!
      Legion::Events.emit('test.event', data: 'hello')
      stats = Legion::Extensions::React::Runners::React.react_stats
      expect(stats[:rule_count]).to eq(1)
    end

    it 'ignores react.* events to prevent loops' do
      Legion::Extensions::React.subscribe!
      # This should not cause infinite recursion
      Legion::Events.emit('react.dispatched', rule_id: :test)
    end
  end
end
