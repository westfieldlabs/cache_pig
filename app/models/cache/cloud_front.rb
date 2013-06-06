class Cache::CloudFront < Cache

  def default_config
    {
      'timeout_seconds' => 1200,
      'max_per_req' => 1000,
      'use_path_only' => true,
    }
  end

  def cdn
    Fog::CDN.new({
      :provider               => 'AWS',
      :aws_access_key_id      => config["access_key"],
      :aws_secret_access_key  => config["secret_key"]
    })
  end

  def purge(target_objects = config['urls'])
    if config['use_path_only']
      target_objects = target_objects.map { |url| path_of(url) }
    end

    if too_many?(target_objects)
      split_and_purge(target_objects, config['max_per_req'])
    else
      invalidate_and_wait(config["distribution_id"], target_objects)
    end
  end

  def as_hash
    {'options' => {'strategy' => 'CloudFront'}.merge(options)}
  end

private

  def path_of(url)
    URI.parse(url).path
  rescue URI::InvalidURIError
    url
  end

  def invalidate_and_wait(distribution_id, objects)
    response = cdn.post_invalidation(distribution_id, objects)
    id = response.body['Id']
    Fog.wait_for(config['timeout_seconds']) { cdn.get_invalidation(config['distribution_id'], id).body['Status'] == 'Completed' }

    # TODO: Should we handle Excon::Errors::BadRequest or Fog::Errors::TimeoutError or let sidekiq deal with them?
  end

end
