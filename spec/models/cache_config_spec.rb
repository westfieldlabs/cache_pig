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

require 'spec_helper'

describe CacheConfig do

  context "with no caches.yml file provided" do

    before do
      File.stub(:exists? => nil)
      CacheConfig.load_caches_info
    end

    it "sets CacheConfig.all to an empty hash" do
      CacheConfig.all.should ==  {}
    end

  end

  context "with a caches yml file provided" do

    before do
      CacheConfig.load_caches_info('spec/support/example_cache_config.yml')
    end

    it "loads the provided caches.yml config file" do
      CacheConfig.all.should_not be_empty
    end

    it "allows reloading of config" do
      CacheConfig.all = {}
      CacheConfig.all.should be_empty
      CacheConfig.load_caches_info('spec/support/example_cache_config.yml')
      CacheConfig.all.keys.should include("akamai_example_server_one")
    end

  end

  it "returns a cache_config hash" do

    CacheConfig.find_by_name("cloud_front_example_server_one").should == {
      "strategy"=>"CloudFront", 
      "access_key"=>"123", 
      "secret_key"=>"SECRET", 
      "distribution_id"=>"DIST_ID_1",
      "timeout_seconds"=>1200,
      "urls"=>["/au/images/"]
    }

  end

end
