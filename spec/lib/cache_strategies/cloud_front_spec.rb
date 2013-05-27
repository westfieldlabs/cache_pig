require 'spec_helper'

describe CacheStrategies::CloudFront do
  describe '#clear' do
    let(:cdn) { double('cdn', :post_invalidation => response) }
    let(:cache) { Cache.new(:cache_type => 'CloudFront') }
    let(:response) { double('response', :body => {'Id'=>'0'}) }

    before do
      Fog::CDN.stub(:new => cdn)
    end

    it 'should create cdn with config' do
      Fog::CDN.should_receive(:new).with(
        { :provider => 'AWS',
          :aws_access_key_id => anything,
          :aws_secret_access_key => anything,
        }
      )

      cache.clear
    end

    it 'should post invalidation with default objects' do
      cdn.should_receive(:post_invalidation).with('DIST_ID', ['/default.html'])
      cache.clear
    end

    context 'when objects specified' do
      it 'should post invalidation with specified objects' do
        cdn.should_receive(:post_invalidation).with('DIST_ID', ['obj'])
        cache.clear(['obj'])
      end
    end

    it "should return response body's id" do
      expect(cache.clear).to eq('0')
    end
  end
end
