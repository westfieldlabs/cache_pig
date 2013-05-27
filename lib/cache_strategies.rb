module CacheStrategies
  include CacheStrategies::Varnish
  include CacheStrategies::Memcached
  include CacheStrategies::Akamai
  include CacheStrategies::F5
  include CacheStrategies::CloudFront

  def clear(target_objects = nil)
    # checks the cache type and calls the method from the appropriate module
    case self.cache_type
    when 'Akamai'
      # do akamai stuff
    when 'Varnish'
      # do varnish stuff
    when 'CloudFront'
      post_invalidation(target_objects)
    end
  end

end
