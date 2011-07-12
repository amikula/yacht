require 'yacht/loader'

class Yacht
  class Barnacle
    class Task
      include ::Rake::DSL if defined?(::Rake::DSL)

      def initialize(task_name = "barnacle", desc = "Run Yacht's lint tool, Barnacle.")
        @task_name, @desc = task_name, desc

        yield self if block_given?

        define_task
      end

      def define_task #:nodoc:
        desc @desc
        task @task_name do
          Barnacle.new.run
        end
      end
    end

    def run
      @config = Yacht::Loader.base_config

      find_keys_not_overridden(@config).each do |key|
        puts "The value \"#{key}\" in the default environment is never overridden, consider using a constant"
      end
    end

    def flatten_keys(hash, prefix=nil, collector={})
      hash.each_pair do |key,value|
        prefixed_key = [prefix,key].compact.join('.')

        if value.is_a?(Hash)
          flatten_keys(value, prefixed_key, collector)
        else
          collector[prefixed_key] = value
        end
      end

      collector
    end

    def find_keys_not_overridden(hash)
      hash = hash.dup

      # TODO: Unhappy path: what if default is not present, or isn't a hash?
      default = hash.delete('default')

      default_keys = flatten_keys(default).keys

      hash.values.each do |environment_hash|
        default_keys -= flatten_keys(environment_hash).keys
      end

      default_keys
    end
  end
end
