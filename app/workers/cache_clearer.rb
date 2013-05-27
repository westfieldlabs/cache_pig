class CacheClearer
 include Sidekiq::Worker

  def perform(cache_hash)
    cache = Cache.new(cache_hash)
    cache.clear
  end

end
