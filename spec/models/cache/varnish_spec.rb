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

  describe '#basename' do
    it 'should be Varnish' do
      expect(Cache::Varnish.new.basename).to eq('Varnish')
    end
  end
end
