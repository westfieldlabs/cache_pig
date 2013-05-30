require 'spec_helper'

describe CacheClearer do
  describe '#perform' do
    before do
      @cache = Cache::CloudFront.new
      @cache.stub(:purge)
    end

    it "should use cache model's clear when performing synchronously" do
      Cache::CloudFront.stub(:new).and_return(@cache)
      @cache.should_receive(:purge)
      CacheClearer.new.perform(@cache.as_hash)
    end

    it 'should perform asynchronously' do
      expect {
        CacheClearer.perform_async(@cache.as_hash)
      }.to change(CacheClearer.jobs, :size).by(1)
    end

    it 'should sybolized keys for Cache object creation' do
      Cache.should_receive(:instance_for).with(:cache_type => 'CloudFront').and_return(@cache)
      CacheClearer.new.perform('cache_type' => 'CloudFront')
    end
  end

  describe '#push_to_queue' do
    it 'should push to a specified queue' do
      CacheClearer.push_to_queue('CloudFront', [{}])
      expect(CacheClearer.jobs.last["queue"]).to eq("CloudFront")
    end
  end
end
