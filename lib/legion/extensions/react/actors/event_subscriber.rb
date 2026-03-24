# frozen_string_literal: true

module Legion
  module Extensions
    module React
      module Actor
        class EventSubscriber < Legion::Extensions::Actors::Once
          def runner_class    = 'Legion::Extensions::React'
          def runner_function = 'subscribe!'
          def check_subtask?  = false
          def generate_task?  = false
        end
      end
    end
  end
end
