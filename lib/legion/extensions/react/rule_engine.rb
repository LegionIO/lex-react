# frozen_string_literal: true

module Legion
  module Extensions
    module React
      class RuleEngine
        attr_reader :rules

        def initialize(rules_hash = {})
          @rules = parse_rules(rules_hash)
        end

        def self.from_settings
          rules_hash = if defined?(Legion::Settings) && !Legion::Settings[:react].nil?
                         Legion::Settings.dig(:react, :rules) || {}
                       else
                         {}
                       end
          new(rules_hash)
        rescue StandardError
          new({})
        end

        def match(event)
          event_name = event[:event].to_s
          @rules.select do |rule|
            Helpers::EventMatcher.match?(rule[:source], event_name) &&
              Helpers::EventMatcher.evaluate_condition(rule[:condition], event)
          end
        end

        private

        def parse_rules(rules_hash)
          rules_hash.filter_map do |id, config|
            next unless config.is_a?(Hash) && config[:enabled] != false

            {
              id:        id.to_sym,
              source:    config[:source].to_s,
              condition: config[:condition],
              autonomy:  (config[:autonomy] || 'observe').to_s.downcase.to_sym,
              chain:     Array(config[:chain])
            }
          end
        end
      end
    end
  end
end
