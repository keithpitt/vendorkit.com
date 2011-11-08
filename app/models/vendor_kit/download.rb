module VendorKit
  class Download < ActiveRecord::Base

    belongs_to :version, :counter_cache => true

    validates :version, :presence => true

    scope :latest, order('created_at desc')

  end
end
