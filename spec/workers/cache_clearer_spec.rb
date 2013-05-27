require 'spec_helper'

describe CacheClearer do
  context '#perform' do
    it "should use cache model's clear when performing synchronously" do
      @cache = Cache.new
      Cache.stub(:new).and_return(@cache)
      @cache.should_receive(:clear)
      CacheClearer.new.perform(Cache.new)
    end

    it 'should perform asynchronously' do
      @cache = Cache.new
      expect {
        CacheClearer.perform_async(@cache)
      }.to change(CacheClearer.jobs, :size).by(1)
    end
  end
end
