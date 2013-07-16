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

class CacheConfig

  cattr_accessor :all
  
  def self.load_caches_info(config_file='config/caches.yml')
    if File.exists?(config_file)
      self.all = YAML::load_file(config_file)
    else
      Rails.logger.warn "Config file '#{config_file}' cannot be found"
      self.all = {}
    end
  end

  def self.find_by_name(name)
    all.select { |k,v| k == name }[name]
  end

  # We could add a find_by_group method in here, which would look for any caches
  # in the config with the specified group, so that an array of caches could be 
  # purged with one call to the API.

end
