require 'spec_helper'

describe CacheClearer do

  let(:cache) { Cache::CloudFront.new(:name => 'cloud_front_example_server_one') }

  it "calls purge on the cache" do
    cache.should_receive(:purge)
    CacheClearer.perform_async(cache)
  end

end