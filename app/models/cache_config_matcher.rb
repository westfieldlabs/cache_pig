#    Copyright 2013 Westfield Digital Pty Ltd
# 
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

# Given a params hash, this class matches the params[:url] (and params[:urls]) with all appropriate config hashes
# in config/caches.yml, and returns a hash like this:
# {"akamai_server_one" => ["http://www.something.com/something","http://www.another.com/another"],
#   "akamai_server_two" => ["http://www.another.com/another","http://www.somethingelse.com/somethingelse"],
#   "cloudfront_server" => ["http://www.somethingelse.com/somethingelse"]}
# Note that urls can be matched with any number of config hashes, in case more than one strategy is used on a url,
# or multiple instances of one strategy purge the same url with different config
class CacheConfigMatcher

  def self.sort_urls_into_hashes(params)
    urls_grouped_by_cache_config_name = {}
    urls_as_array(params).each do |url|
      CacheConfig.all.each do |config_hash_name,config_hash|
        if url_matches_urls_in_config_hash?(url, config_hash)
          urls_grouped_by_cache_config_name[config_hash_name]||=[]
          urls_grouped_by_cache_config_name[config_hash_name] << url
        end
      end
    end
    urls_grouped_by_cache_config_name
  end

  def self.urls_as_array(params)
    (Array(params[:url])+Array(params[:urls])).map{|url| url.split(/[\s|,]/)}.flatten.compact.map{|url| url.gsub(/\A["']|["']\Z/, '')}
  end

  def self.url_matches_urls_in_config_hash?(url,config_hash)
    Array(config_hash["urls"]).detect do |url_from_config_hash|
      if url_from_config_hash[0] == "/" && url_from_config_hash[url_from_config_hash.length-1] == "/"
        Regexp.new(url_from_config_hash.as_regexp[0]).match(url)
      else
        url_from_config_hash == url
      end
    end
  end

end
