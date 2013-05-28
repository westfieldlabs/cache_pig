class Cache::CloudFront < Cache

  def default_config
    {
      :objects => ['/default.html'],
      :timeout_seconds => 1200,
    }
  end

  def cdn
    Fog::CDN.new({
      :provider               => 'AWS',
      :aws_access_key_id      => config["access_key"],
      :aws_secret_access_key  => config["secret_key"]
    })

  end

  def purge(target_objects = objects)
    begin 
      response = cdn.post_invalidation(config["distribution_id"], target_objects)
      id = response.body['Id']
      Fog.wait_for(config[:timeout_seconds]) { cdn.get_invalidation(config[:distribution_id], id).body['Status'] == 'Completed' }
    rescue Excon::Errors::BadRequest
      # if there are 3 'In Progress' already, the call returns code 400, and results in Excon::Errors::BadRequest
      # flag this as retry later?
      raise
    rescue Fog::Errors::TimeoutError
      raise
    end
  end

  def as_hash
    { :cache_type => 'CloudFront' }.merge(options)
  end
end
