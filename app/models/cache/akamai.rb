class Cache::Akamai < Cache
  def default_config
    {
      'max_per_req' => 100,
      'purge_method' => 'invalidate', # or 'remove'
    }
  end

  def purge(target_objects = (config['urls'] || []))
    if too_many?(target_objects)
      split_and_purge(target_objects)
    else
      issue_purge(target_objects)
    end
  end

  def issue_purge(target_objects)
    # TODO: this should not be merged every time
    AkamaiApi.config.merge! :auth => [config['username'], config['password']]
    response = AkamaiApi::Ccu.purge config['purge_method'].to_sym, :arl, target_objects
    if too_many_current_invalidations?(response)
      # pause this queue, add this job itself to default queue
      Sidekiq::Queue[basename].pause
      CacheClearer.client_push('class' => CacheClearer, 'queue' => 'default', 'args' => [as_hash])
    elsif error_response?(response)
      raise "Error #{response.code} rereturned from Akamai: \n" + response.body
    else
      Sidekiq::Queue[basename].unpause
    end
  end

  def as_hash
    options
  end

private
  def error_response?(response)
    response.code >= 300
  end

  def too_many_current_invalidations?(response)
    response.code == 332
  end
end
