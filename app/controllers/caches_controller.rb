class CachesController < ApplicationController

  def create
    @caches = Cache.instances_for(CacheConfigMatcher.sort_urls_into_hashes(params))
    @caches.map{|c| Sidekiq::Client.enqueue_to(c.basename, CacheClearer, c.as_hash) }
    render json: @caches.map(&:urls)
  end

end