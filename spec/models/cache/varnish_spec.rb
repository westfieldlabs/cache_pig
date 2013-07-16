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

describe Cache::Varnish do
  describe '#purge' do
    let(:cache) { Cache::Varnish.new('name' => 'varnish_example_server_one') }
    
    it 'should create a rest-client request with config' do
      RestClient.should_receive(:get).at_least(:once) do |url, options|
        cache.config["urls"].should include(url)
        options.should == {
          :cache_control=>"no-cache", 
          :timeout => 2
        }
      end
      cache.purge
    end

    it "times out if the varnish server isn't responding" do
      stub_request(:any, /.*/).to_timeout
      expect { cache.purge }.to raise_error(RestClient::RequestTimeout)
    end

  end

  describe "with no proxies specified" do

    let(:cache) { Cache::Varnish.new('name' => 'varnish_example_server_one') }

    it "should send the purge request straight to the urls" do
      cache.stub(:config).and_return({
        "proxies" => nil,
        "urls" => ["http://www.acme.com/au/images/clusters/2013/banner/lbobo-may-2914.jpg"]})
      RestClient.should_receive(:get).once do |url, options|
        cache.config["urls"].should include(url)
        options.should == {
          :cache_control=>"no-cache", 
          :timeout => 2
        }
      end
      cache.purge
    end

  end

  describe '#basename' do
    it 'should be Varnish' do
      expect(Cache::Varnish.new.basename).to eq('Varnish')
    end
  end
end
