class NotifierObserver < ActiveRecord::Observer

  observe VendorKit::Version

  def after_create(version)
    Resque.enqueue(TwitterUpdater, version.id)
  end

end
