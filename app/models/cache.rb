class Cache
  attr_accessor :options

  def initialize(options = {})
    @options = options
  end

  def config
    check_default_config.merge(yml_config).merge(options)
  end

  def yml_config
    if options[:name]
      CacheConfig.find_by_name(options[:name])
    elsif options[:address]
      CacheConfig.find_by_address(options[:address])
    else
      {}
    end
  end

  def check_default_config
    respond_to?(:default_config) ? default_config : {}
  end

  def strategy
    self.class
  end

  def objects
    config[:objects]
  end

  def purge
    raise NotImplementedError, 'You have to subclass Cache.'
  end

  def as_hash
    raise NotImplementedError, 'You have to subclass Cache.'
  end

  def self.instance_for(options)
    # TODO: should we check whitelist and use constantize?
    case options.delete(:cache_type)
    when 'CloudFront'
      Cache::CloudFront.new(options)
    when 'Varnish'
      Cache::Varnish.new(options)
    else
      # raise?
    end
  end
end
