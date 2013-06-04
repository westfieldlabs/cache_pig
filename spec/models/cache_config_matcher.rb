require 'spec_helper'

describe CacheConfigMatcher do

  describe '#sort_urls_into_hashes' do
    context 'creating a hash of urls using config hash names as keys' do

      it "returns a hash given one url" do
        params = {:url => "/au/images/clusters/2013/banner/image.jpeg"}
        result = CacheConfigMatcher.sort_urls_into_hashes(params)
        result.should == {"cloud_front_example_server_one"=>["/au/images/clusters/2013/banner/image.jpeg"]}
      end

      it "returns a hash given multiple urls that are space-separated" do
        params = {:url => "/au/images/clusters/2013/banner/image.jpeg http://www.westfield.com.au/fountaingate/news-and-events/food-and-lifestyle/recipes/"}
        result = CacheConfigMatcher.sort_urls_into_hashes(params)
        result.should == {
          "cloud_front_example_server_one"=>["/au/images/clusters/2013/banner/image.jpeg"],
          "varnish_example_server_one" => ["http://www.westfield.com.au/fountaingate/news-and-events/food-and-lifestyle/recipes/"]
        }
      end

      it "returns a hash given multiple urls that are comma-separated" do
        params = {:url => "/au/images/clusters/2013/banner/image.jpeg,http://www.westfield.com.au/fountaingate/news-and-events/food-and-lifestyle/recipes/"}
        result = CacheConfigMatcher.sort_urls_into_hashes(params)
        result.should == {
          "cloud_front_example_server_one"=>["/au/images/clusters/2013/banner/image.jpeg"],
          "varnish_example_server_one" => ["http://www.westfield.com.au/fountaingate/news-and-events/food-and-lifestyle/recipes/"]
        }
      end

      it "returns a hash given multiple urls that are comma- and space-separated" do
        params = {:url => "/au/images/clusters/2013/banner/image.jpeg, http://www.westfield.com.au/fountaingate/news-and-events/food-and-lifestyle/recipes/"}
        result = CacheConfigMatcher.sort_urls_into_hashes(params)
        result.should == {
          "cloud_front_example_server_one"=>["/au/images/clusters/2013/banner/image.jpeg"],
          "varnish_example_server_one" => ["http://www.westfield.com.au/fountaingate/news-and-events/food-and-lifestyle/recipes/"]
        }
      end

      it "returns a hash when passed urls in params[:urls] instead of params[:url]" do
        params = {:urls => "/au/images/clusters/2013/banner/image.jpeg"}
        result = CacheConfigMatcher.sort_urls_into_hashes(params)
        result.should == {"cloud_front_example_server_one"=>["/au/images/clusters/2013/banner/image.jpeg"]}
      end
    end
  end

  describe "#url_matches_urls_in_config_hash" do

    let(:config_hash) { :strategy => "Akamai", :urls => ["http://cdnsa1.atwestfield.com/au/images/banner.jpg"],
      "http://cdnsa1.atwestfield.com/au/styles/style.css",
      "/ /"


    it "returns true if the url is in the config hash" do
      config_hash = {:strategy => "Akamai", :urls => ["http://cdnsa1.atwestfield.com/au/images/banner.jpg"]}
    end

    it "returns false if th url is not in the config hash"

    it "returns true if the url matches a regex in the config hash"

    it "returns false if the url doesn't match a regex in the config hash"
  end

end