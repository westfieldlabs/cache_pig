class CacheConfig

  cattr_accessor :all
  
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

  def self.find_by_strategy(strategy)
    all.detect { |k,v| v[:strategy] == strategy }[1]
  end

  def self.find_by_proxy_address(address)
    all.detect { |k,v| v[:proxy_address] == proxy_address }[1]
  end

  def self.by_urls(urls)
    all.select { |k,v| (v[:urls] & urls).any? }
  end

end