class PagesController < ApplicationController

  def index
    @latest_vendors = VendorKit::Vendor.latest.includes(:user).limit(5)
    @downloaded_vendors = VendorKit::Vendor.downloaded.includes(:user).limit(5)
    @updated_vendors = VendorKit::Vendor.updated.includes(:user).limit(5)
  end

  def documentation
    # Nothing
  end

end
