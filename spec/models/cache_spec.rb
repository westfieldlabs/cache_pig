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

  describe '.instance_for(options)' do
    context 'when varnish specified' do
      it 'should create varnish cache instance' do
        expect(Cache.instance_for(:cache_type => 'Varnish')).to be_instance_of(Cache::Varnish)
      end
    end

    context 'when cloudfront specified' do
      it 'should create cloudfront cache instance' do
        expect(Cache.instance_for(:cache_type => 'CloudFront')).to be_instance_of(Cache::CloudFront)
      end
    end
  end
end
