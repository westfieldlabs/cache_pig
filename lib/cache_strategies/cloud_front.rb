module CacheStrategies::CloudFront
  def config
    {
      :access_key => '123',
      :secret_key => 'SECRET',
      :distribution_id => 'DIST_ID',
      :default_objects => ['/default.html'],
    }
  end

  def cdn
    @cdn ||= Fog::CDN.new({
      :provider               => 'AWS',
      :aws_access_key_id      => config[:access_key],
      :aws_secret_access_key  => config[:secret_key]
    })

  end

  def post_invalidation(target_objects = nil)
    target_objects ||= config[:default_objects]

    begin 
      response = cdn.post_invalidation(config[:distribution_id], target_objects)
      response.body['Id']
    rescue Excon::Errors::BadRequest
      # if there are 3 'In Progress' already, the call returns code 400, and results in Excon::Errors::BadRequest
      # flag this as retry later?
    end
  end
end
