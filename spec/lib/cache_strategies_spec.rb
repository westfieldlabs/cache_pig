require 'spec_helper'

describe CacheStrategies do
  let(:cache) { Cache.new }

  describe '#clear' do
    it "should call cache strategy implementation's clear" do
      cache.cache_type = 'CloudFront'
      cache.should_receive(:post_invalidation)
      cache.clear
    end
  end
end
