class CachesController < ApplicationController

  def create
    @cache = Cache.instance_for(params[:cache])
    #CacheClearer.perform_async(@cache.as_hash)

    # TODO: when these classes are DRYed, the above statement should just work
    # or, could we perhaps use this: sidekiq_options :queue => :CloudFront
    CacheClearer.push_to_queue(@cache.basename, [@cache.as_hash])
    render json: @cache
  end

end
