require 'spec_helper'

describe "Config Loader" do

  before do

  end

  context "with no caches.yml file provided" do

    before do
      File.stub(:exists?).and_return(false)
      ConfigLoader.load_caches_info
    end

    it "sets CACHE_CONFIG to an empty hash" do
      Cachepig::Application.config.caches.should ==  {}
    end

  end

  context "with a caches.yml file provided" do

    before do
      ConfigLoader.load_caches_info
    end

    it "loads the provided caches.yml config file" do
      Cachepig::Application.config.caches.should_not be_empty
    end

    it "provides access to the hash via a config method on the Cache class" do
      Cache.config.should_not be_empty
    end

    it "allows reloading of config" do
      Cache.config.keys.should_not include("new_cached_content_server_name")
      ConfigLoader.load_caches_info('spec/support/example_cache_config.yml')
      Cache.config.keys.should include("new_cached_content_server_name")
    end

  end

end