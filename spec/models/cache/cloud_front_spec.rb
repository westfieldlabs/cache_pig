require 'spec_helper'

describe Cache::CloudFront do
  describe '#purge' do
    let(:cdn) { double('cdn', :post_invalidation => response, :get_invalidation => response) }
    let(:cache) { Cache::CloudFront.new('name' => 'cloud_front_example_server_one', 'strategy' => 'CloudFront') }
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

    # TODO: this depends on config file content.
    it 'should post invalidation with default objects' do
      cdn.should_receive(:post_invalidation).with('DIST_ID_1', ['/au/images/'])
      cache.purge
    end

    # TODO: this depends on config file content.
    context 'when objects specified' do
      it 'should post invalidation with specified objects' do
        cdn.should_receive(:post_invalidation).with('DIST_ID_1', ['obj'])
        cache.purge(['obj'])
      end
    end

    it "should timeout if not completing" do
      cache_timeout = Cache::CloudFront.new(cache.config.merge('timeout_seconds' => 1))
      response.stub(:body => {'Id'=>'0', 'Status' => 'InProgress'})
      expect { cache_timeout.purge }.to raise_error(Fog::Errors::TimeoutError)
    end

    context 'when 2001 objects given' do
      let(:array_2001) { (1..2001).map { |i| "#{i}.txt" } }

      it 'should create new cache purge oject' do
        expect {
          cache.purge(array_2001)
        }.to change(CacheClearer.jobs, :size).by(3)
      end

      it 'should make 1000, 1000, and 1 object' do
        cache.purge(array_2001)
        jobs = CacheClearer.jobs[-3..-1]
        expect(jobs[0]['args'][0]['options']['urls'].size).to eq(1000)
        expect(jobs[1]['args'][0]['options']['urls'].size).to eq(1000)
        expect(jobs[2]['args'][0]['options']['urls'].size).to eq(1)
      end
    end

    context 'when use_path_only is configured true' do
      it 'should modify urls to not have protocol and domain' do
        cache.options['use_path_only'] = true
        cdn.should_receive(:post_invalidation).with(anything, ['/foo/bar', '/bar/foo', '/foo'])
        cache.purge(['http://www.example.com/foo/bar', 'http://www.example2.com/bar/foo', '/foo'])
      end
    end

    context 'when use_path_only is configured false' do
      it 'should pass full urls' do
        cache.options['use_path_only'] = false
        cdn.should_receive(:post_invalidation).with(anything, ['http://www.example.com/foo/bar', 'http://www.example2.com/bar/foo', '/foo'])
        cache.purge(['http://www.example.com/foo/bar', 'http://www.example2.com/bar/foo', '/foo'])
      end
    end
  end

  describe '#basename' do
    it 'should be CloudFront' do
      expect(Cache::CloudFront.new.basename).to eq('CloudFront')
    end
  end
end
