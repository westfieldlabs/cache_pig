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

class Cache::CloudFront < Cache

  def default_config
    {
      # See http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Invalidation.html#InvalidationLimits
      'timeout_seconds' => 900,
      'max_per_req' => 1000,
      'use_path_only' => true,
    }
  end

  def cdn
    Fog::CDN.new({
      :provider               => 'AWS',
      :aws_access_key_id      => config["access_key"],
      :aws_secret_access_key  => config["secret_key"]
    })
  end

  def purge(target_objects = config['urls'])
    if config['use_path_only']
      target_objects = target_objects.map { |url| path_of(url) }
    end
    if too_many?(target_objects)
      split_and_purge(target_objects, config['max_per_req'])
    else
      invalidate_and_wait(config["distribution_id"], target_objects)
    end
  end

private

  def path_of(url)
    URI.parse(url).path
  end

  def invalidate_and_wait(distribution_id, objects)
    Rails.logger.debug "DEBUG CloudFront Invalidation distribution_id=#{distribution_id} objects=#{objects.inspect}"
    begin
      response = cdn.post_invalidation(distribution_id, objects)
      id = response.body['Id']
      Fog.wait_for(config['timeout_seconds']) { cdn.get_invalidation(config['distribution_id'], id).body['Status'] == 'Completed' }
    # TODO: Should we handle Excon::Errors::BadRequest or Fog::Errors::TimeoutError or let sidekiq deal with them?
    rescue =>e
      Rails.logger.debug "DEBUG CloudFront Invalidation error"
      Rails.logger.debug e.backtrace
      Rails.logger.warn "WARN CloudFront Invalidation error #{e.message}"
      raise e
    end
  end

end
