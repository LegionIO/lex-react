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
      end
    end
  end
end
