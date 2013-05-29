require 'spec_helper'

describe Cache::CloudFront do
  describe '#purge' do
    let(:cdn) { double('cdn', :post_invalidation => response, :get_invalidation => response) }
    let(:cache) { Cache::CloudFront.new(:name => 'cloud_front_example_server_one', :strategy => 'CloudFront') }
    let(:response) { double('response', :body => {'Id'=>'0', 'Status' => 'Completed'}) }

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

      cache.purge
    end

    it 'should post invalidation with default objects' do
      cdn.should_receive(:post_invalidation).with('DIST_ID', ['/default.html'])
      cache.purge
    end

    context 'when objects specified' do
      it 'should post invalidation with specified objects' do
        cdn.should_receive(:post_invalidation).with('DIST_ID', ['obj'])
        cache.purge(['obj'])
      end
    end

    it "should timeout if not completing" do
      cache_timeout = Cache::CloudFront.new(cache.config.merge(:timeout_seconds => 1))
      response.stub(:body => {'Id'=>'0', 'Status' => 'InProgress'})
      expect { cache_timeout.purge }.to raise_error(Fog::Errors::TimeoutError)
    end
  end

  describe '#basename' do
    it 'should be CloudFront' do
      expect(Cache::CloudFront.new.basename).to eq('CloudFront')
    end
  end
end
