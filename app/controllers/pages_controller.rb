class PagesController < ApplicationController

  def index
    @latest_vendors = VendorKit::Vendor.latest.limit(5)
  end

end
