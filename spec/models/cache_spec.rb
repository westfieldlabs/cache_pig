require 'spec_helper'

describe Cache do

  let(:cache) { Cache::CloudFront.new(:name => 'cloud_front_example_server_one') }

  it "returns the strategy" do
    cache.strategy.should == "CloudFront"
  end

  it "returns the yml config hash from the caches name" do
    cache.yml_config.should == {
      "strategy"=>"CloudFront", 
      "access_key"=>"123", 
      "secret_key"=>"SECRET", 
      "distribution_id"=>"DIST_ID", 
      "target_objects"=>["test.html"]
    }
  end

  it "returns an empty yml config hash if the name is nil" do
    cache.options[:name] = nil
    cache.yml_config.should == {}
  end

  it "returns an empty yml config hash if the name is not a key in the config file" do
    cache.options[:name] = "something"
    cache.yml_config.should == {}
  end

end