require 'spec_helper'

describe VendorKit::User do

  let(:user) { FactoryGirl.create(:user) }

  it { should have_many(:versions) }
  it { should have_many(:vendors) }

  it "should create an API token after create" do
    user.authentication_token = nil
    user.save

    user.authentication_token.should_not be_nil
  end

  describe "#find_for_database_authentication"do

    it "should allow you to login via a username" do
      VendorKit::User.find_for_database_authentication(:login => user.username).should == user
    end

    it "should allow you to authenticate via an email address" do
      VendorKit::User.find_for_database_authentication(:login => user.email).should == user
    end

  end

  describe "#find_record" do

    it "should return a user matching the username" do
      VendorKit::User.find_record(user.username).should == user
    end

    it "should return a user matching the email address" do
      VendorKit::User.find_record(user.email).should == user
    end

  end

end
