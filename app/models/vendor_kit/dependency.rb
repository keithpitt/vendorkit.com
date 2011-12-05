module VendorKit
  class Dependency < ActiveRecord::Base

    belongs_to :version

    default_scope order('name ASC')

  end
end
