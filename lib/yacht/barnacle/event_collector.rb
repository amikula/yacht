require 'yacht/barnacle'

class Yacht
  class Barnacle
    class EventCollector
      attr_reader :duplicates
      attr_reader :environments

      def initialize
        @keys = []
        @duplicates = {}
        @environments = []
      end

      def push_key(key)
        @keys << key
      end

      def pop_key
        @keys.pop
      end

      def report_duplicate(value)
        @duplicates[self.environments.dup << @keys.join('.')] = value
      end
    end
  end
end
