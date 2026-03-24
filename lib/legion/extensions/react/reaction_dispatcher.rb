# frozen_string_literal: true

module Legion
  module Extensions
    module React
      class ReactionDispatcher
        def initialize(loop_breaker:)
          @loop_breaker = loop_breaker
        end

        def dispatch(rule:, event:, depth: 0)
          event_id = event[:event].to_s

          unless @loop_breaker.allow?(rule_id: rule[:id].to_s, depth: depth, event_id: event_id)
            log_blocked(rule, event)
            return { success: false, rule_id: rule[:id], reason: :loop_blocked }
          end

          if rule[:autonomy] == :observe
            log_observed(rule, event)
            return { success: true, rule_id: rule[:id], action: :observed, chain: rule[:chain] }
          end

          execute_chain(rule, event)
          @loop_breaker.record(rule_id: rule[:id].to_s, event_id: event_id)

          { success: true, rule_id: rule[:id], action: :dispatched, chain: rule[:chain] }
        rescue StandardError => e
          { success: false, rule_id: rule[:id], error: e.message }
        end

        private

        def execute_chain(rule, event)
          rule[:chain].each do |runner_ref|
            dispatch_runner(runner_ref, event, rule)
          end
        end

        def dispatch_runner(runner_ref, event, rule)
          Legion::Events.emit('react.dispatched',
                              rule_id:      rule[:id],
                              runner_ref:   runner_ref,
                              source_event: event[:event],
                              autonomy:     rule[:autonomy])
        rescue StandardError => e
          Legion::Logging.warn "[React] dispatch error: #{e.message}" if defined?(Legion::Logging)
        end

        def log_observed(rule, event)
          return unless defined?(Legion::Logging)

          Legion::Logging.info "[React] OBSERVE rule=#{rule[:id]} event=#{event[:event]} chain=#{rule[:chain]}"
        end

        def log_blocked(rule, event)
          return unless defined?(Legion::Logging)

          Legion::Logging.warn "[React] BLOCKED rule=#{rule[:id]} event=#{event[:event]} (loop prevention)"
        end
      end
    end
  end
end
