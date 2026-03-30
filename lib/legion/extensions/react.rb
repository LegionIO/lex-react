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
      extend Legion::Extensions::Core if Legion::Extensions.const_defined?(:Core, false)

      class << self
        include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

        def data_required?
          false
        end

        def remote_invocable?
          false
        end

        def subscribe!
          return unless defined?(Legion::Events)

          @subscribe ||= Legion::Events.on('*') do |event| # rubocop:disable ThreadSafety/ClassInstanceVariable
            next if event[:event].to_s.start_with?('react.')

            Runners::React.handle_event(event: event)
          rescue StandardError => e
            log.warn "[React] event handler error: #{e.message}"
          end
        end

        def unsubscribe!
          return unless @subscribe && defined?(Legion::Events) # rubocop:disable ThreadSafety/ClassInstanceVariable

          Legion::Events.off('*', @subscribe) # rubocop:disable ThreadSafety/ClassInstanceVariable
          @subscribe = nil # rubocop:disable ThreadSafety/ClassInstanceVariable
        end

        unless method_defined?(:log)
          def log
            Legion::Logging
          end
        end
      end

      require_relative 'react/actors/event_subscriber'
    end
  end
end
