require 'spec_helper'

describe CacheClearer do
  context '#perform' do
    before do
      @cache = Cache.new
    end

    it "should use cache model's clear when performing synchronously" do
      Cache.stub(:new).and_return(@cache)
      @cache.should_receive(:clear)
      CacheClearer.new.perform(Cache.new.as_hash)
    end

    it 'should perform asynchronously' do
      expect {
        CacheClearer.perform_async(@cache.as_hash)
      }.to change(CacheClearer.jobs, :size).by(1)
    end

    it 'should sybolized keys for Cache object creation' do
      Cache.should_receive(:new).with(:cache_type => 'CloudFront').and_return(@cache)
      CacheClearer.new.perform('cache_type' => 'CloudFront')
    end
  end
end
