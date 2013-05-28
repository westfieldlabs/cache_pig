class CacheClearer
 include Sidekiq::Worker

  def perform(cache)
    cache.purge
  end

end
