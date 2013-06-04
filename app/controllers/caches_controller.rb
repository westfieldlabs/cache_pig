class CachesController < ApplicationController

  def create
    @caches = Cache.instances_for(CacheConfigMatcher.sort_urls_into_hashes(params))
    render json: @caches.map{|cache| CacheClearer.push_to_queue(cache.basename, [cache]) }
  end

end
