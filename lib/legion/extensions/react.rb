# frozen_string_literal: true

require 'legion/extensions/react/version'

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
