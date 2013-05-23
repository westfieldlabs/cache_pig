class Cache
  include CacheStrategies
  def self.config
    Cachepig::Application.config.caches
  end
end