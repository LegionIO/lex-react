# frozen_string_literal: true

module Legion
  module Extensions
    module React
      module Helpers
        module EventMatcher
          module_function

          def match?(pattern, event_name)
            # Use placeholder so '.**' double-star replacement isn't re-processed by single '*' gsub
            regex_str = pattern.gsub('.**', '__DS__')
                               .gsub('*', '[^.]*')
                               .gsub('__DS__', '\..*')
            regex_str = "\\A#{regex_str}\\z"
            Regexp.new(regex_str).match?(event_name)
          rescue RegexpError => _e
            false
          end

          def evaluate_condition(condition, event)
            return true if condition.nil? || condition.strip.empty?

            # Parse simple conditions: "key == 'value'" or "key != 'value'"
            if condition =~ /\A(\w+)\s*(==|!=)\s*'([^']*)'\z/
              key    = Regexp.last_match(1).to_sym
              op     = Regexp.last_match(2)
              value  = Regexp.last_match(3)
              actual = event[key]&.to_s

              case op
              when '==' then actual == value
              when '!=' then actual != value
              else false
              end
            else
              false
            end
          rescue StandardError => _e
            false
          end
        end
      end
    end
  end
end
