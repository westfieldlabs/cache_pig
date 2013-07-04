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
    Rails.logger.debug "DEBUG Varnish Invalidation url=#{url} headers=#{headers.inspect} proxy=#{proxy.inspect}"
    begin
      response = RestClient.get url, headers
      ["#{url}#{proxy ? ' (via '+proxy+')' : ''})", response]
    rescue RestClient::RequestTimeout
      raise
    end
  end

end


