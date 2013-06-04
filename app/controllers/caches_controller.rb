class CachesController < ApplicationController

  def create
    @caches = Cache.instances_for(CacheConfigMatcher.sort_urls_into_hashes(params))
    render json: @caches.map{|c| CacheClearer.push_to_queue(c.basename, [c.as_hash]) }
  end

end
