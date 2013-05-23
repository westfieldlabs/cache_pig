module ConfigLoader

  def self.load_caches_info(config_file = 'config/caches.yml')
    if File.exists?(config_file)
      Cachepig::Application.config.caches = YAML::load_file(config_file)
    else
      Rails.logger.warn "Config file '#{config_file}' cannot be found"
      Cachepig::Application.config.caches = {}
    end
  end

end

ConfigLoader.load_caches_info