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

end