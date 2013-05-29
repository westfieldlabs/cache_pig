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
        expect(Cache.new(:name => 'foo').yml_config).to eq('found by name')
      end
    end

    context 'when address given' do
      it 'should find by address' do
        expect(Cache.new(:address => 'bar').yml_config).to eq('found by address')
      end
    end

    context 'when both given' do
      it 'should find by name' do
        expect(Cache.new(:name => 'foo', :address => 'bar').yml_config).to eq('found by name')
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
      cache = Cache.new(:objects => ['object'])
      expect(cache.objects).to eq(['object'])
    end
  end

  describe '#purge' do
    it 'should raise not implemented' do
      expect { Cache.new.purge }.to raise_error( NotImplementedError )
    end
  end

  describe '#as_hash' do
    it 'should raise not implemented' do
      expect { Cache.new.as_hash }.to raise_error( NotImplementedError )
    end
  end

  describe '#basename' do
    it 'should be Cache' do
      expect(Cache.new.basename).to eq('Cache')
    end
  end

  describe '.instance_for(params)' do
    context 'when varnish server name specified' do
      it 'should return varnish cache instance' do
        expect(Cache.instance_for(:name => 'varnish_example_server_one')).to be_instance_of(Cache::Varnish)
      end
    end

    context 'when varnish specified by cache type' do
      it 'should create varnish cache instance' do
        expect(Cache.instance_for(:cache_type => 'Varnish')).to be_instance_of(Cache::Varnish)
      end
    end

    context 'when cloudfront specified by cache type' do
      it 'should create cloudfront cache instance' do
        expect(Cache.instance_for(:cache_type => 'CloudFront')).to be_instance_of(Cache::CloudFront)
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
