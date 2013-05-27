class Cache
  include CacheStrategies
  attr_accessor :cache_type

  def self.config
    Cachepig::Application.config.caches
  end

  def initialize(options = {})
    @cache_type = options[:cache_type]
  end

  def purge
    send("purge_#{cache_type}_cache")
    puts "\nFINISHED PURGING #{cache_type} CACHE."
  end

end