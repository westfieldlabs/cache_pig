#    Copyright 2013 Westfield Digital Pty Ltd
# 
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
# 
#       http://www.apache.org/licenses/LICENSE-2.0
# 
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

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

  end

  describe '#push_to_queue' do
    it 'should push to a specified queue' do
      CacheClearer.push_to_queue('CloudFront', [{}])
      expect(CacheClearer.jobs.last["queue"]).to eq("CloudFront")
    end
  end
end
