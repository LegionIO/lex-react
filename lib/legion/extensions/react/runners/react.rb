# frozen_string_literal: true

module Legion
  module Extensions
    module React
      module Runners
        module React
          module_function

          def handle_event(event:)
            engine     = rule_engine
            matches    = engine.match(event)
            dispatcher = reaction_dispatcher

            results = matches.map do |rule|
              dispatcher.dispatch(rule: rule, event: event, depth: event[:react_depth] || 0)
            end

            {
              success:       true,
              matched_rules: matches.size,
              results:       results
            }
          rescue StandardError => e
            { success: false, error: e.message }
          end

          def react_stats
            engine        = rule_engine
            breaker_stats = loop_breaker.stats

            {
              success:             true,
              rule_count:          engine.rules.size,
              reactions_this_hour: breaker_stats[:reactions_this_hour],
              max_per_hour:        breaker_stats[:max_per_hour]
            }
          rescue StandardError => e
            { success: false, error: e.message }
          end

          def reset!
            @rule_engine         = nil
            @loop_breaker        = nil
            @reaction_dispatcher = nil
          end

          def rule_engine
            @rule_engine ||= RuleEngine.from_settings
          end

          def loop_breaker
            @loop_breaker ||= begin
              settings = react_settings
              Helpers::LoopBreaker.new(
                max_depth:        settings[:max_depth] || Helpers::Constants::DEFAULT_MAX_DEPTH,
                cooldown_seconds: settings[:cooldown_seconds] || Helpers::Constants::DEFAULT_COOLDOWN_SECONDS,
                max_per_hour:     settings[:max_reactions_per_hour] || Helpers::Constants::DEFAULT_MAX_REACTIONS_PER_HOUR
              )
            end
          end

          def reaction_dispatcher
            @reaction_dispatcher ||= ReactionDispatcher.new(loop_breaker: loop_breaker)
          end

          def react_settings
            return {} unless defined?(Legion::Settings) && !Legion::Settings[:react].nil?

            Legion::Settings[:react] || {}
          rescue StandardError
            {}
          end

          private_class_method :rule_engine, :loop_breaker, :reaction_dispatcher, :react_settings
        end
      end
    end
  end
end
