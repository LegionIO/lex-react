# frozen_string_literal: true

require 'legion/extensions/react/version'
require_relative 'react/helpers/constants'
require_relative 'react/helpers/event_matcher'
require_relative 'react/helpers/loop_breaker'
require_relative 'react/rule_engine'
require_relative 'react/reaction_dispatcher'
require_relative 'react/runners/react'

module Legion
  module Extensions
    module React
      extend Legion::Extensions::Core if Legion::Extensions.const_defined?(:Core)

      class << self
        def data_required?
          false
        end

        def remote_invocable?
          false
        end

        def subscribe!
          return unless defined?(Legion::Events)

          @subscription ||= Legion::Events.on('*') do |event|
            next if event[:event].to_s.start_with?('react.')

            Runners::React.handle_event(event: event)
          rescue StandardError => e
            Legion::Logging.warn "[React] event handler error: #{e.message}" if defined?(Legion::Logging)
          end
        end

        def unsubscribe!
          return unless @subscription && defined?(Legion::Events)

          Legion::Events.off('*', @subscription)
          @subscription = nil
        end
      end

      require_relative 'react/actors/event_subscriber' if defined?(Legion::Extensions::Actors::Once)
    end
  end
end
