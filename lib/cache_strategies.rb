module CacheStrategies
  include CacheStrategies::Varnish
  include CacheStrategies::Memcached
  include CacheStrategies::Akamai
  include CacheStrategies::F5

  def clear
    # checks the cache type and calls the method from the appropriate module
  end

end