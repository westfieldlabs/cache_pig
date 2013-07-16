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

class Cache::Varnish < Cache

  def request_headers
    {
      :cache_control => 'no-cache',
      :timeout => 2
    }
  end

  def purge
    urls = config["urls"]
    headers = request_headers.merge(config["request_headers"] || {})
    proxies = Array(config["proxies"])
    if proxies.any?
      proxies.each do |proxy|
        RestClient.proxy = proxy
        urls.map { |url| send_purge_request(url, headers, proxy) }
      end
    else
      urls.map { |url| send_purge_request(url, headers, nil) }
    end
  end

  def send_purge_request(url, headers, proxy = nil)
    Rails.logger.debug "DEBUG Varnish Invalidation url=#{url} headers=#{headers.inspect} proxy=#{proxy.inspect} method=#{config["request_method"]}"
    begin
      if config["request_method"] == "head"
        response = RestClient.head url, headers
      else
        if config["request_method"]
          Rails.logger.warn "Ignoring invalid request_headers from configuration value=#{config["request_method"]}"
        end
        response = RestClient.get url, headers
      end
      ["#{url}#{proxy ? ' (via '+proxy+')' : ''})", response]
    rescue RestClient::RequestTimeout, RestClient::ResourceNotFound => e
      Rails.logger.warn "Varnish status=404 url=#{url} message=#{e.message}"
    end
  end

end


