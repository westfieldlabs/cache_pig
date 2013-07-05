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


