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
      config = Yacht::Loader.base_config

      report_keys_not_overridden(config)
      report_popular_values(config)
    end

    def report_keys_not_overridden(config)
      keys_not_overridden = find_keys_not_overridden(config)
      keys_not_overridden.sort!

      unless keys_not_overridden.empty?
        keys_string, is_are = keys_not_overridden.length == 1 ? ["key", "is"] : ["keys", "are"]

        puts "The following #{keys_string} in the default environment #{is_are} never overridden, consider using a constant:"
        keys_not_overridden.each do |key|
          puts "    #{key}"
        end
      end
    end

    def report_popular_values(config)
      config = config.dup
      config.delete('default')
      num_environments = config.length

      report = report_override_values(config)

      report.each_pair do |key,value_report|
        next if key == '_parent'

        total_overrides = value_report.values.inject(0){|sum,v| sum+v}

        defaulted_environments_count = num_environments - total_overrides

        max_override_count = value_report.values.sort.last
        if max_override_count > defaulted_environments_count
          puts "The value for \"#{key}\" is often overridden to \"#{value_report.invert[max_override_count]}\", consider changing the default"
        end
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

    def report_override_values(hash)
      hash = hash.dup
      hash.delete('default')

      retval = Hash.new{|h,k| h[k] = Hash.new(0) }

      # TODO: Unhappy path: what if one or more of the values is not a Hash?
      hash.values.each do |env_config|
        flattened = flatten_keys(env_config)

        flattened.each_pair do |k,v|
          retval[k][v] += 1
        end
      end

      retval
    end
  end
end
