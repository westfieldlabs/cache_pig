require 'spec_helper'

describe Cache::Varnish do
  describe '#purge' do
    let(:cache) { Cache::Varnish.new(:name => 'varnish_example_server_one') }

    before do
      Cache::Varnish.stub(:system => true)
    end

    it "executes a curl command to purge the cache" do
      cache.should_receive(:system).at_least(:once) do |arg|
        arg.should match /curl -m 2 -H 'Cache-control: no-cache' -x \S* -I \S* -s/
      end
      cache.purge
    end

    it "execute a curl command for each of the 'urls' and 'proxies' combinations in the config" do
      expected_number_of_cache_expiry_calls = cache.config["urls"].size * cache.config["proxies"].size
      cache.should_receive(:system).exactly(expected_number_of_cache_expiry_calls).times
      cache.purge
    end

    describe '#basename' do
      it 'should be Varnish' do
        expect(Cache::Varnish.new.basename).to eq('Varnish')
      end
   end

  end
end
