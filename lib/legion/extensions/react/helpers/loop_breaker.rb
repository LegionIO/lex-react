# frozen_string_literal: true

module Legion
  module Extensions
    module React
      module Helpers
        class LoopBreaker
          def initialize(max_depth: Constants::DEFAULT_MAX_DEPTH,
                         cooldown_seconds: Constants::DEFAULT_COOLDOWN_SECONDS,
                         max_per_hour: Constants::DEFAULT_MAX_REACTIONS_PER_HOUR)
            @max_depth        = max_depth
            @cooldown_seconds = cooldown_seconds
            @max_per_hour     = max_per_hour
            @recent           = [] # Array of { rule_id:, event_id:, at: }
            @mutex            = Mutex.new
          end

          def allow?(rule_id:, depth:, event_id: nil)
            return false if depth > @max_depth

            @mutex.synchronize do
              prune_old_entries
              return false if @recent.size >= @max_per_hour

              if event_id && @cooldown_seconds.positive?
                duplicate = @recent.any? do |r|
                  r[:rule_id] == rule_id && r[:event_id] == event_id
                end
                return false if duplicate
              end

              true
            end
          end

          def record(rule_id:, event_id:)
            @mutex.synchronize do
              @recent << { rule_id: rule_id, event_id: event_id, at: Time.now }
            end
          end

          def reactions_this_hour
            @mutex.synchronize do
              prune_old_entries
              @recent.size
            end
          end

          def stats
            @mutex.synchronize do
              prune_old_entries
              { reactions_this_hour: @recent.size, max_per_hour: @max_per_hour }
            end
          end

          private

          def prune_old_entries
            cutoff = Time.now - 3600
            @recent.reject! { |r| r[:at] < cutoff }
          end
        end
      end
    end
  end
end
