class Cache
  include CacheStrategies
  attr_accessor :cache_type

  def initialize(options = {})
    @cache_type = options[:cache_type]
  end

  def as_hash
    { :cache_type => cache_type }
  end
end
