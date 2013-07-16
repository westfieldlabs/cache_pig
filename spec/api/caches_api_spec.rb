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

describe CachesController, :type => :api do

  context "purging a single valid url" do

    let(:url) { "/caches?url='http://www.acme.com/au/images/'" }

    it "responds with the Added to X Queue message" do
      post url
      response.body.should eql("{\"http://www.acme.com/au/images/\":[\"Added to Cache::CloudFront queue\"]}")
    end

  end

  context "purging multiple valid urls using multiple strategies" do

    let(:url) { "/caches?url='http://www.acme.com/au/images/,http://acme.com/au/images/clusters/2013/banner/lbobo-may-m-z-strip.jpg'" }

    it "responds with a Added to X Queue message for each" do
      post url
      response.body.should eql(
        "{\"http://www.acme.com/au/images/\":[\"Added to Cache::CloudFront queue\"],\"http://acme.com/au/images/clusters/2013/banner/lbobo-may-m-z-strip.jpg\":[\"Added to Cache::CloudFront queue\",\"Added to Cache::Akamai queue\"]}"
        )
    end

  end

  context "purging a single valid url that uses multiple strategies" do

    let(:url) { "/caches?url='http://www.acme.com/au/images/clusters/2013/banner/lbobo-may-2914.jpg'" }

    it "responds with the Added to X Queue message and lists both strategies" do
      post url
      response.body.should eql("{\"http://www.acme.com/au/images/clusters/2013/banner/lbobo-may-2914.jpg\":[\"Added to Cache::Varnish queue\",\"Added to Cache::CloudFront queue\"]}")
    end

  end
    
  context "unsuccessful requests" do

    let(:url) { "/caches?url='http://www.acme.com/au/images/'" }
    let(:missing_url) { "caches?url='this-url-isnt-in-the-config-file'" }

    it "provides a config missing message if the url isn't applicable to any strategies" do
      post missing_url
      response.body.should eql("{\"this-url-isnt-in-the-config-file\":\"Could not find cache config for 'this-url-isnt-in-the-config-file'\"}")
    end

    let(:bad_urls) { 
      ["caches?urls='''''''''''''''''''''''''''",
       "caches?urls=eval(@current_user)"
      ]
    }

    it "doesnt die a horrible death when given bad urls" do
      bad_urls.each do |bad_url|
        post bad_url
        response.body.should match("Could not find cache config")
      end
    end

    context "an unresponsive queue" do # Not sure if this can happen or not?

      before do
        CacheClearer.stub(:push_to_queue).and_return(nil)
      end

      it "provides an informative message saying there was a problem" do
        post url
        response.body.should eql("{\"http://www.acme.com/au/images/\":[\"CloudFront queue did not respond while adding http://www.acme.com/au/images/\"]}")
      end

    end

  end

  context "overriding config from the YAML" do

    let(:url) { "/caches?url='http://www.acme.com/au/images/'&cache[secret_key]=ABC123" }
    let!(:cache) { Cache::CloudFront.new("urls"=>["http://www.acme.com/au/images/"]) } 

    it "should replace values in the config hash with params" do
      Cache::CloudFront.should_receive(:new).with({
        "strategy"=>"CloudFront", 
        "access_key"=>"123", 
        "secret_key"=>"ABC123", 
        "distribution_id"=>"DIST_ID_1", 
        "timeout_seconds"=>1200, 
        "urls"=>["http://www.acme.com/au/images/"]
        }).and_return(cache)

      post url
    end

  end
end
