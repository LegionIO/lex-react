# frozen_string_literal: true

module Legion
  module Extensions
    module React
      module Helpers
        module Constants
          AUTONOMY_LEVELS = %i[observe filter transform autonomous].freeze

          AUTONOMY_THRESHOLDS = {
            observe:    0.0,
            filter:     0.3,
            transform:  0.6,
            autonomous: 0.8
          }.freeze

          DEFAULT_MAX_DEPTH              = 3
          DEFAULT_COOLDOWN_SECONDS       = 60
          DEFAULT_MAX_REACTIONS_PER_HOUR = 100
        end
      end
    end
  end
end
