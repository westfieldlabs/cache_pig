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

describe Cache do
  describe '#config' do
    it 'should be options' do
      expect(Cache.new(:foo => :bar).config).to eq({:foo => :bar})
    end
  end

  describe '#yml_config' do
    before do
      CacheConfig.stub(:find_by_name => 'found by name')
      CacheConfig.stub(:find_by_address => 'found by address')
    end

    context 'when name given' do
      it 'should find by name' do
        expect(Cache.new('name' => 'foo').yml_config).to eq('found by name')
      end
    end

    context 'when address given' do
      it 'should find by address' do
        expect(Cache.new('address' => 'bar').yml_config).to eq('found by address')
      end
    end

    context 'when both given' do
      it 'should find by name' do
        expect(Cache.new('name' => 'foo', :address => 'bar').yml_config).to eq('found by name')
      end
    end

    context 'when neither given' do
      it 'should be empty' do
        expect(Cache.new.yml_config).to eq({})
      end
    end
  end

  describe '#check_default_config' do
    it 'should be empty' do
      expect(Cache.new.check_default_config).to eq({})
    end
  end

  describe '#strategy' do
    it 'should be its class' do
      expect(Cache.new.strategy).to eq(Cache)
    end

    context 'when called for subclass' do
      it 'should be full class name' do
        expect(Cache::CloudFront.new.strategy).to eq(Cache::CloudFront)
      end
    end
  end

  describe '#objects' do
    it "should be config's objects" do
      cache = Cache.new('objects' => ['object'])
      expect(cache.objects).to eq(['object'])
    end
  end

  describe '#purge' do
    it 'should raise not implemented' do
      expect { Cache.new.purge }.to raise_error( NotImplementedError )
    end
  end

  describe '#basename' do
    it 'should be Cache' do
      expect(Cache.new.basename).to eq('Cache')
    end
  end

  describe '.instances_for(urls_grouped_by_cache_config_name)' do

    context 'with one url param' do

      context 'with a varnish url given' do

        let(:caches) { Cache.instances_for("varnish_example_server_one" => 
          'http://www.westfield.com.au/fountaingate/news-and-events/food-and-lifestyle/recipes/') }
        
        it "returns an array with one Cache::Varnish object in it" do
          caches.size.should == 1
          caches[0].should be_instance_of(Cache::Varnish)
        end

      end

      context 'with a CloudFront url given' do

        let(:caches) { Cache.instances_for("cloud_front_example_server_one" => 
          '/au/images/clusters/2013/banner/image.jpeg') }

        it "returns an array with one Cache::CloudFront object in it" do
          caches.size.should == 1
          caches[0].should be_instance_of(Cache::CloudFront)
        end

      end

      context 'with a akamai url given' do

        let(:caches) { Cache.instances_for("akamai_example_server_one" => 
          'http://cdnsa1.atwestfield.com/au/images/clusters/2013/banner/lbobo-may-m-z-strip.jpg') }

        it "returns an array with one Cache::CloudFront object in it" do
          caches.size.should == 1
          caches[0].should be_instance_of(Cache::Akamai)
        end

      end

    end

    context "multiple urls using the same strategy from the same config hash" do

      let(:caches) { Cache.instances_for("akamai_example_server_one" => [
        'http://cdnsa1.atwestfield.com/au/images/clusters/2013/banner/lbobo-may-m-z-strip.jpg',
        'http://www.westfield.com.au/au/images/clusters/2013/banner/pete-evans-may-banner.jpg'
        ]) }

      it "returns an array with one Cache::Akamai object in it, with 2 urls" do
        caches.size.should == 1
        caches[0].should be_instance_of(Cache::Akamai)
        caches[0].urls.should == [
          'http://cdnsa1.atwestfield.com/au/images/clusters/2013/banner/lbobo-may-m-z-strip.jpg',
          'http://www.westfield.com.au/au/images/clusters/2013/banner/pete-evans-may-banner.jpg'
        ]
      end

    end

    context "multiple urls using the same strategy with different config" do
      # eg: at the top level of caches.yml, there might be > 1 config hashes for Akamai,
      # so we need to create different Cache objects for each.
      let(:caches) { Cache.instances_for("cloud_front_example_server_one" => ['/au/images/clusters/2013/banner/image.jpeg'],
        "cloud_front_example_server_two" => ['/au/images/clusters/2013/banner/something.jpg']) }

      it "returns an array of two Cache::CloudFront instances with different distribution_ids" do
        caches.size.should == 2
        caches.each_with_index do |c,index|
          c.should be_instance_of(Cache::CloudFront)
          c.options["distribution_id"].should == "DIST_ID_#{index+1}"
        end
      end

    end

    context "multiple urls and multiple strategies" do
      # eg: at the top level of caches.yml, there might be > 1 config hashes for Akamai,
      # so we need to create different Cache objects for each.
      let(:caches) { Cache.instances_for("cloud_front_example_server_one" => ['/au/images/clusters/2013/banner/image.jpeg'],
        "cloud_front_example_server_two" => ['/au/images/clusters/2013/banner/something.jpg'],
        "varnish_example_server_one" => ['http://www.westfield.com.au/fountaingate/news-and-events/food-and-lifestyle/recipes/',
          "http://cdnsa1.atwestfield.com/fountaingate/news-and-events/food-and-lifestyle/recipes/"]) }

      it "returns an array of three Cache::CloudFront instances and one Cache::Varnish instance" do
        caches.size.should == 3
        caches[0].should be_instance_of(Cache::CloudFront)
        caches[0].urls.should == ['/au/images/clusters/2013/banner/image.jpeg']
        caches[1].should be_instance_of(Cache::CloudFront)
        caches[1].urls.should == ['/au/images/clusters/2013/banner/something.jpg']
        caches[2].should be_instance_of(Cache::Varnish)
        caches[2].urls.should == ['http://www.westfield.com.au/fountaingate/news-and-events/food-and-lifestyle/recipes/',
          "http://cdnsa1.atwestfield.com/fountaingate/news-and-events/food-and-lifestyle/recipes/"]
      end

    end

    context "a single url that pertains to multiple strategies" do

      let(:caches) { Cache.instances_for("varnish_example_server_one" => ["http://www.westfield.com.au/au/images/clusters/2013/banner/lbobo-may-2914.jpg"], 
        "varnish_example_server_two" => ["http://www.westfield.com.au/au/images/clusters/2013/banner/lbobo-may-2914.jpg"]) }
      
      it "returns an array of two Cache::Varnish instances" do
        caches.size.should == 2
        caches.each do |c|
          c.should be_instance_of(Cache::Varnish)
        end
      end
    end
  end

  describe '.cache_type_for(params)' do
    context 'when cache type specified' do
      it 'should be specifed cache type' do
        expect(Cache.cache_type_for(:cache_type => 'CloudFront')).to eq('CloudFront')
      end
    end

    context 'when varnish server name given' do
      it 'should be Varnish' do
        expect(Cache.cache_type_for(:name => 'varnish_example_server_one')).to eq('Varnish')
      end
    end

    context 'when cloudfront server name given' do
      it 'should be CloudFront' do
        expect(Cache.cache_type_for(:name => 'cloud_front_example_server_one')).to eq('CloudFront')
      end
    end
  end
end
