class Cache::Varnish < Cache

  def purge
    Array(config["urls"]).each do |url|
      config['proxies'].each do |proxy|
        curl_cmd = "curl -m 2 -H 'Cache-control: no-cache' -x #{proxy} -I #{url} -s"
        result = system(curl_cmd)
      end
    end

  end

end