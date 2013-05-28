class CacheConfig

  cattr_accessor :all

  def self.all
    if @@all.nil?
      self.load_caches_info
    end
    @@all
  end
  
  def self.load_caches_info(config_file='config/caches.yml')
    if File.exists?(config_file)
      self.all = YAML::load_file(config_file)
    else
      Rails.logger.warn "Config file '#{config_file}' cannot be found"
      self.all = {}
    end
  end

  def self.find_by_name(name)
    all.select { |k,v| k == name }[name]
  end

  # We could add a find_by_group method in here, which would look for any caches
  # in the config with the specified group, so that an array of caches could be 
  # purged with one call to the API.

end