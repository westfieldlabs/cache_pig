class CacheClearer
  include Sidekiq::Worker

  def perform(cache_hash)
    cache = Cache.instance_for(cache_hash.symbolize_keys)
    cache.purge
  end

end