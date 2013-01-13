FactoryGirl.define do

  sequence :username do |n|
    "user#{n}"
  end

  factory :user, :class => "VendorKit::User" do
    username
    email                 { Forgery(:internet).email_address }
    password              'password'
    password_confirmation 'password'
  end

end
