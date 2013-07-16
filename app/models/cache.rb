#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
# 
#       http://www.apache.org/licenses/LICENSE-2.0
# 
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

class Cache
  attr_accessor :options

  def initialize(options = {})
    @options = options
  end

  def config
    check_default_config.merge(yml_config).merge(options)
  end

  def yml_config
    if options['name']
      CacheConfig.find_by_name(options['name'])
    elsif options['address']
      CacheConfig.find_by_address(options['address'])
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
    config['objects']
  end

  def urls
    options["urls"]
  end

  def purge
    raise NotImplementedError, 'You have to subclass Cache.'
  end

  def as_hash
    {'options' => {'strategy' => basename}.merge(options)}
  end

  def basename
    self.class.to_s.sub(/^.*::/, '')
  end

  # Given a hash of urls grouped by cache_config_name, creates an array of cache objects
  # expects a hash like {"akamai_server_one" => ["http://url_to_purge","http://another_url_to_purge"]}
  def self.instances_for(urls_grouped_by_cache_config_name,params={})
    cache_objects = []    
    urls_grouped_by_cache_config_name.map do |cache_config_name,urls|
      cache_config_hash = CacheConfig.all[cache_config_name]
      cache_objects << "Cache::#{cache_config_hash['strategy'].classify}".constantize.new(
        cache_config_hash.merge(params[:cache] || {}).merge("urls" => urls)
      )
    end
    cache_objects
  end

  def self.cache_type_for(params)
    class_name = params.delete(:cache_type)
    if class_name.blank?
      cache_conf = CacheConfig.find_by_name(params[:name])
      class_name = cache_conf['strategy'] if cache_conf
    end
    class_name
  end

protected

  def split_and_purge(objects, slice_size = config['max_per_req'])
    objects.each_slice(slice_size) do |slice|
      # TODO: this method shouldn't know about details of cache clearer.
      CacheClearer.client_push('class' => CacheClearer, 'queue' => basename, 'args' => [{'options' => as_hash['options'].merge({'urls' => slice})}])
    end
  end

  def too_many?(target_objects)
    target_objects.size > config['max_per_req']
  end

end
