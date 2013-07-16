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

describe Cache::Akamai do
  let(:akamai) { Cache::Akamai.new('name' => 'akamai_test') }
  let(:response) { double('response', :code => 100, :body => '') }

  before do
    AkamaiApi::Ccu.stub(:purge => response)
    CacheConfig.stub(:find_by_name).and_return({})
  end

  describe '#purge' do
    it 'should create connection with provided config' do
      CacheConfig.stub(:find_by_name).and_return({'username' => 'username', 'password' => 'password'})
      AkamaiApi.config.should_receive(:merge!).with(
        :auth  => [ 'username', 'password' ]
      )
      akamai.purge
    end

    it 'should call Connection#purge with objects' do
      AkamaiApi::Ccu.should_receive(:purge).with( :invalidate, :arl, ['http://example.com/foo', 'http://example.com/bar']).and_return(response)
      akamai.purge(['http://example.com/foo', 'http://example.com/bar'])
    end

    it 'should timeout if not completing' do
      AkamaiApi::Ccu.unstub(:purge)
      stub_request(:any, /.*/).to_timeout
      expect { akamai.purge }.to raise_error(Timeout::Error)
    end

    context 'when more than 100 objects given' do
      let(:array_201) { (1..201).map { |i| "#{i}.txt" } }

      it 'should add new objects in the queue' do
        expect {
          akamai.purge(array_201)
        }.to change(CacheClearer.jobs, :size).by(3)
      end

      it 'should split in 100, 100, 1' do
        akamai.purge(array_201)
        jobs = CacheClearer.jobs[-3..-1]
        expect(jobs[0]['args'][0]['options']['urls'].size).to eq(100)
        expect(jobs[1]['args'][0]['options']['urls'].size).to eq(100)
        expect(jobs[2]['args'][0]['options']['urls'].size).to eq(1)
      end
    end

    context 'when Error 332 is returned' do
      before do
        AkamaiApi::Ccu.stub(:purge).and_return(response)
        response.stub(:code).and_return(332)
      end

      it 'should pause queue' do
        akamai.purge([:foo])
        expect(Sidekiq::Queue['Akamai']).to be_paused
      end

      it 'should add itself to the default queue' do
        expect {
          akamai.purge([:foo])
        }.to change{CacheClearer.jobs.select{|j| j["queue"] == "default"}.size}.by(1)
      end

    end

    context 'when some other error (eg 399) returned' do
      before do
        AkamaiApi::Ccu.stub(:purge).and_return(response)
        response.stub(:code).and_return(399)
      end

      it 'should raise exception' do
        expect {
          akamai.purge([:foo])
        }.to raise_error(StandardError)
      end
    end

    context 'when it succeeds' do
      before do
        Sidekiq::Queue['Akamai'].pause
      end

      it 'should unpause the queue' do
        expect(Sidekiq::Queue['Akamai']).to be_paused
        akamai.purge([:foo])
        expect(Sidekiq::Queue['Akamai']).to_not be_paused
      end
    end
  end

  describe '#basename' do
    it 'should be "Akamai"' do
      expect(Cache::Akamai.new.basename).to eq('Akamai')
    end
  end
end
