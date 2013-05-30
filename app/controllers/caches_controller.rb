class CachesController < ApplicationController

  def create
    @caches = Cache.instances_for(CacheConfigMatcher.sort_urls_into_hashes(params))
    CacheClearer.perform_async(@cache, 'queue' => @cache.basename)
    render json: @caches.map(&:urls)
  end

end