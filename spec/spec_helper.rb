# frozen_string_literal: true

require 'bundler/setup'

# Stub Legion framework modules
module Legion
  module Extensions
    module Core; end

    module Actors
      class Every; end # rubocop:disable Lint/EmptyClass
      class Subscription; end # rubocop:disable Lint/EmptyClass
      class Once; end # rubocop:disable Lint/EmptyClass
    end
  end

  module Transport
    class Exchange; end # rubocop:disable Lint/EmptyClass
    class Queue; end # rubocop:disable Lint/EmptyClass
    class Message; end # rubocop:disable Lint/EmptyClass
  end

  module Settings
    def self.[](key)
      @data ||= {}
      @data[key]
    end

    def self.dig(*keys)
      @data ||= {}
      keys.reduce(@data) { |h, k| h.is_a?(Hash) ? h[k] : nil }
    end

    def self.set_test_data(data) # rubocop:disable Naming/AccessorMethodName
      @data = data
    end
  end

  module Events
    class << self
      def listeners
        @listeners ||= Hash.new { |h, k| h[k] = [] }
      end

      def on(event_name, &block)
        listeners[event_name.to_s] << block
        block
      end

      def off(event_name, block = nil)
        if block
          listeners[event_name.to_s].delete(block)
        else
          listeners.delete(event_name.to_s)
        end
      end

      def emit(event_name, **payload)
        event = { event: event_name.to_s, timestamp: Time.now, **payload }
        listeners[event_name.to_s].each { |l| l.call(event) }
        listeners['*'].each { |l| l.call(event) }
        event
      end

      def clear
        @listeners = nil
      end

      def listener_count(event_name = nil)
        if event_name
          listeners[event_name.to_s].size
        else
          listeners.values.sum(&:size)
        end
      end
    end
  end

  module Logging
    def self.debug(_msg) = nil
    def self.info(_msg) = nil
    def self.warn(_msg) = nil
    def self.error(_msg) = nil
  end
end

require 'legion/extensions/react'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.order = :random
  config.before { Legion::Events.clear }
end
