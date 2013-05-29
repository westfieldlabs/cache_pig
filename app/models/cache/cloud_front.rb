class Cache::CloudFront < Cache

  def default_config
    {
      :objects => ['/default.html'],
      :timeout_seconds => 1200,
      :max_per_req => 1000,
    }
  end

  def cdn
    Fog::CDN.new({
      :provider               => 'AWS',
      :aws_access_key_id      => config["access_key"],
      :aws_secret_access_key  => config["secret_key"]
    })

  end

  def split_and_purge(objects)
    objects.each_slice(config[:max_per_req]) do |slice|
      # TODO: this method shouldn't know about details of cache clearer.
      CacheClearer.client_push('class' => CacheClearer, 'queue' => basename, 'args' => [as_hash.merge({:objects => slice})])
    end
  end

  def too_many?(objects)
    objects.size > config[:max_per_req]
  end

  def purge(target_objects = objects)
    if too_many?(target_objects)
      split_and_purge(target_objects)
    else
      response = cdn.post_invalidation(config["distribution_id"], target_objects)
      id = response.body['Id']
      Fog.wait_for(config[:timeout_seconds]) { cdn.get_invalidation(config['distribution_id'], id).body['Status'] == 'Completed' }
    end

    # TODO: Should we handle Excon::Errors::BadRequest or Fog::Errors::TimeoutError or let sidekiq deal with them?
  end

  def as_hash
    { :cache_type => 'CloudFront' }.merge(options)
  end
end
