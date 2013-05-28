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
    self.class # .name.gsub("Cache::","")
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

  def basename
    self.class.to_s.sub(/^.*::/, '')
  end

  def self.instance_for(params)
    # TODO: should we check whitelist and use constantize?
    case self.cache_type_for(params)
    when 'CloudFront'
      Cache::CloudFront.new(params)
    when 'Varnish'
      Cache::Varnish.new(params)
    else
      # raise?
    end
  end

  def self.cache_type_for(params)
    class_name = params.delete(:cache_type)
    if class_name.blank?
      cache_conf = CacheConfig.find_by_name(params[:name])
      class_name = cache_conf['strategy'] if cache_conf
    end
    class_name
  end
end