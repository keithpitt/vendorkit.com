FactoryGirl.define do

  sequence :vendor_name do |n|
    "vendor#{n}"
  end

  factory :vendor, :class => "VendorKit::Vendor" do
    name        { FactoryGirl.generate(:vendor_name) }
    association :user

    after(:build) do |vendor|
      vendor.versions.build :user => vendor.user, :number => "0.1"
    end
  end

end
