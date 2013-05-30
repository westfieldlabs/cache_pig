class CacheClearer
  include Sidekiq::Worker

  def perform(cache_hash)
    cache = Cache.instance_for(cache_hash.symbolize_keys)
    cache.purge
  end

  def self.push_to_queue(queue, data)
    self.client_push('class' => self, 'queue' => queue, 'args' => data)
  end
end
