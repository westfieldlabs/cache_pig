class Cache
  attr_accessor :options

  def initialize(options = {})
    @options = options.symbolize_keys
  end

  def config
    check_default_config.merge(yml_config).merge(options)
  end

  def yml_config
    if options[:name] && CacheConfig.all.keys.include?(options[:name])
      CacheConfig.find_by_name(options[:name])
    else
      {}
    end
  end

  def check_default_config
    respond_to?(:default_config) ? default_config : {}
  end

  def strategy
    self.class.name.gsub("Cache::","")
  end

  def objects
    config[:objects]
  end

end