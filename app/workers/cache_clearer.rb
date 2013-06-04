class CacheClearer
  include Sidekiq::Worker

  def perform(cache)
    cache.purge
  end

  def self.push_to_queue(queue, data)
    self.client_push('class' => self, 'queue' => queue, 'args' => data)
  end
end
