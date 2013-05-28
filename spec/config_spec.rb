require 'spec_helper'

describe "Config Loader" do

  context "with no caches.yml file provided" do

    before do
      File.stub(:exists? => nil)
      CacheConfig.load_caches_info
    end

    it "sets CacheConfig.all to an empty hash" do
      CacheConfig.all.should ==  {}
    end

  end

  context "with a caches.yml file provided" do

    before do
      CacheConfig.load_caches_info
    end

    it "loads the provided caches.yml config file" do
      CacheConfig.all.should_not be_empty
    end

    it "allows reloading of config" do
      CacheConfig.all.keys.should_not include("new_cached_content_server_name")
      CacheConfig.load_caches_info('spec/support/example_cache_config.yml')
      CacheConfig.all.keys.should include("new_cached_content_server_name")
    end

    after do
      CacheConfig.load_caches_info
    end

  end

end