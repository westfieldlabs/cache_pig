class Cache::Akamai < Cache
  def default_config
    {
      :wsdl_endpoint => 'https://ccuapi.akamai.com/soap/servlet/soap/purge',
      :max_per_req => 100,
      :purge_method => 'invalidate', # or 'remove'
    }
  end

  def purge(target_objects = [])
    if too_many?(target_objects)
      split_and_purge(target_objects)
    else
      issue_purge(target_objects)
    end
  end

  def issue_purge(target_objects)
    # TODO: this should not be merged every time
    AkamaiApi.config.merge! :auth => [config[:username], config[:password]]
    response = AkamaiApi::Ccu.purge config[:purge_method].to_sym, :arl, target_objects
    if response.code == 332 # Too many invalidation requests
      # pause this queue, add this job itself to default queue
      Sidekiq::Queue[basename].pause
      CacheClearer.client_push('class' => CacheClearer, 'queue' => 'default', 'args' => [as_hash])
    else
      Sidekiq::Queue[basename].unpause
    end
  end

  def as_hash
    options
  end
end
