FactoryGirl.define do

  factory :version, :class => "VendorKit::Version" do
    number { "#{rand(9)}.#{rand(9)}.#{rand(9)}" }
    user
    vendor
  end

end
