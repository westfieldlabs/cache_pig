class Cache::CloudFront < Cache

  def default_config
    {
      :objects => ['/default.html']
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
      response.body['Id']
    rescue Excon::Errors::BadRequest
      # if there are 3 'In Progress' already, the call returns code 400, and results in Excon::Errors::BadRequest
      # flag this as retry later?
    end
  end

end