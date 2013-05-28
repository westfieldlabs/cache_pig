class CachesController < ApplicationController

  def create
    @cache = Cache.instance_for(params[:cache])
    #CacheClearer.perform_async(@cache.as_hash)
    # TODO: change this. this was done so that we can specify which queue we want to use.
    # when these classes are DRYed, the above statement should just work
    # or, could we perhaps use this: sidekiq_options :queue => :CloudFront
    CacheClearer.client_push('class' => CacheClearer, 'queue' => @cache.basename, 'args' => [@cache.as_hash])
    render json: @cache
  end

end