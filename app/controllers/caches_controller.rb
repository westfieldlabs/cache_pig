class CachesController < ApplicationController

  def create
    @cache = Cache.new(params[:cache])
    CacheClearer.perform_async(@cache)
    render json: @cache
  end

end
