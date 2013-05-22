class CacheClearer
 include Sidekiq::Worker

  def perform(cache)
    cache.clear
  end

end