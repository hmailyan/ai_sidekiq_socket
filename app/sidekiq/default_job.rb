class DefaultJob
  include Sidekiq::Job

  def perform(*args)
    p "START"
    p args
    # Do something
  end
end
