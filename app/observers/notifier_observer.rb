class NotifierObserver < ActiveRecord::Observer

  observe VendorKit::Version

  def after_create(version)
    # Turn off the twitter bot for now
    # Resque.enqueue(TwitterUpdater, version.id)
  end

end
