class Yacht::Loader
  class << self
    # use the current rails environment by default
    def environment
      @environment ||= Rails.env
    end

    def dir
      @dir ||= Rails.root.join('config', 'yacht')
    end

    def full_file_path_for_config(config_type)
      dir.join("#{config_type}.yml")
    end

    # Add current Rails environment to defined keys
    def all_with_rails_env
      all_without_rails_env.merge('rails_env' => Rails.env)
    end
    alias_method_chain :all, :rails_env

  end
end