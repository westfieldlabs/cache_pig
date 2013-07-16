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

class Cache::Akamai < Cache
  def default_config
    {
      'max_per_req' => 100,
      'purge_method' => 'invalidate', # or 'remove'
    }
  end

  def purge(target_objects = (config['urls'] || []))
    if too_many?(target_objects)
      split_and_purge(target_objects)
    else
      issue_purge(target_objects)
    end
  end

  def issue_purge(target_objects)
    # TODO: this should not be merged every time
    AkamaiApi.config.merge! :auth => [config['username'], config['password']]
    response = AkamaiApi::Ccu.purge config['purge_method'].to_sym, :arl, target_objects
    if too_many_current_invalidations?(response)
      # pause this queue, add this job itself to default queue
      Sidekiq::Queue[basename].pause
      CacheClearer.client_push('class' => CacheClearer, 'queue' => 'default', 'args' => [as_hash])
    elsif error_response?(response)
      raise "Error #{response.code} rereturned from Akamai"
    else
      Sidekiq::Queue[basename].unpause
    end
  end

  def as_hash
    {'options' => {'strategy' => 'Akamai'}.merge(options)}
  end

private
  def error_response?(response)
    response.code >= 300
  end

  def too_many_current_invalidations?(response)
    response.code == 332
  end
end
