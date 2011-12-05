class AddDownlaodsCountToVersion < ActiveRecord::Migration
  def change
    add_column :versions, :downloads_count, :integer, :default => 0

    VendorKit::Version.reset_column_information
    VendorKit::Version.all.each { |version|
      VendorKit::Version.update_counters version.id, :downloads_count => version.downloads.count
    }
  end
end
