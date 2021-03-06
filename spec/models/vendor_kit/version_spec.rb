require 'spec_helper'

describe VendorKit::Version do

  it { should belong_to(:vendor) }
  it { should belong_to(:user) }
  it { should have_many(:downloads) }

  it { should validate_presence_of(:number) }
  it { should validate_presence_of(:user) }

  it "should have the package uploader mounted" do
    VendorKit::Version.uploaders[:package].should == PackageUploader
  end

  context "<=>" do

    it "should return versions in the correct order when sorting" do
      versions = [ VendorKit::Version.new(:number => '0.1'),
                   VendorKit::Version.new(:number => '0.0.1'),
                   VendorKit::Version.new(:number => '0.3.15'),
                   VendorKit::Version.new(:number => '4.3.9'),
                   VendorKit::Version.new(:number => '4.3.2'),
                   VendorKit::Version.new(:number => '5.0.alpha'),
                   VendorKit::Version.new(:number => '0.2.5') ]

      versions.sort.map(&:number).should == ["0.0.1", "0.1", "0.2.5", "0.3.15", "4.3.2", "4.3.9", "5.0.alpha"]
    end

  end

  context "#version" do

    it "should return a version object" do
      version = VendorKit::Version.new(:number => "0.2.5")

      version.version.should == Vendor::Version.new("0.2.5")
    end

  end

  context "#destroy" do

    it "should destroy the vendor" do
      vendor = FactoryGirl.create(:vendor)
      vendor.versions.first.destroy

      expect do
        vendor.reload
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should not destroy the vendor if there are multiple versions" do
      vendor = FactoryGirl.create(:vendor)
      other_version = FactoryGirl.create(:version, :vendor => vendor)
      vendor.versions.first.destroy

      expect do
        vendor.reload
      end.to_not raise_error(ActiveRecord::RecordNotFound)
    end

  end

  context "#to_param" do

    it "should return the version number" do
      version = VendorKit::Version.new(:number => "0.2.5")

      version.to_param.should == "0.2.5"
    end

  end

  context "uploading a vendor" do

    it "should load in the vendor spec" do
      vendor = File.open(Rails.root.join("spec", "resources", "vendors", "DKBenchmark-0.1.vendor"))
      version = VendorKit::Version.new(:package => vendor)
      version.save
      version.errors[:package].should be_empty

      version.vendor.name.should == "DKBenchmark"
      version.number.should == "0.1"
    end

    it "should return an error if the vendor package's spec is missing" do
      vendor = File.open(Rails.root.join("spec", "resources", "vendors", "DKBenchmark-0.1-missing.vendor"))
      version = VendorKit::Version.new(:package => vendor)
      version.save

      version.errors[:package].should_not be_empty
    end

    it "should return an error if the vendor package's spec is broken" do
      vendor = File.open(Rails.root.join("spec", "resources", "vendors", "DKBenchmark-0.1-broken.vendor"))
      version = VendorKit::Version.new(:package => vendor)
      version.save

      version.errors[:package].should_not be_empty
    end

    it "should return an error if the vendor has a bad version string" do
      vendor = File.open(Rails.root.join("spec", "resources", "vendors", "DKBenchmark-0.1-bad-version.vendor"))
      version = VendorKit::Version.new(:package => vendor)
      version.save

      version.errors[:package].should_not be_empty
    end

  end

  context 'setting a vendor spec' do

    let(:user) { FactoryGirl.create(:user) }
    let(:other_user) { FactoryGirl.create(:user) }

    let(:existing_vendor_spec) {
        { :authors =>"keithpitt", :files => ["DKBenchmark.h", "DKBenchmark.m"],
          :homepage =>"http://www.keithpitt.com", :source => "https://github.com/keithpitt/DKBenchmark",
          :description =>"Easy benchmarking in Objective-C using blocks", :name => "DKBenchmark",
          :email =>"me@keithpitt.com", :version => "0.1" }
    }

    let(:new_vendor_spec) {
        { "authors"=> ["keithpitt", "mariovisic" ], "files"=>["DKBenchmark.h", "DKBenchmark.m"],
          "homepage"=>"http://www.mariovisic.com", "source"=>"https://github.com/mariovisic/DKBenchmark",
          "description"=>"Easy benchmarking with cheese", "name"=>"DKBenchmark",
          "email"=>"mario@mariovisic.com", "version" => "0.2" }
    }

    let(:newer_vendor_spec) {
        { "authors"=> ["keithpitt", "mariovisic" ], "files"=>["DKBenchmark.h", "DKBenchmark.m"],
          "homepage"=>"http://www.mariovisic.com", "source"=>"https://github.com/mariovisic/DKBenchmark",
          "description"=>"Easy benchmarking with cheese AND BACON!", "name"=>"DKBenchmark",
          "email"=>"mario@mariovisic.com", "version" => "0.2.1" }
    }

    let(:old_vendor_spec) {
        { "authors"=> ["keithpitt", "mariovisic" ], "files"=>["DKBenchmark.h", "DKBenchmark.m"],
          "homepage"=>"http://www.mariovisic.com", "source"=>"https://github.com/mariovisic/DKBenchmark",
          "description"=>"THIS IS THE OLD ONE!!", "name"=>"DKBenchmark",
          "email"=>"mario@mariovisic.com", "version" => "0.0.1" }
    }

    context 'with an existing vendor' do

      let!(:existing) do
        version = VendorKit::Version.create!(:user => user, :vendor_spec => existing_vendor_spec)
        version.reload
        version
      end

      it 'should use an existing vendor owned by the user if it exists' do
        version = VendorKit::Version.new(:user => user, :vendor_spec => new_vendor_spec)
        version.save

        version.vendor.should == existing.vendor
      end

      it "should add an error if the user doesn't own the existing vendor" do
        version = VendorKit::Version.new(:user => other_user, :vendor_spec => new_vendor_spec)

        version.save.should be_false
        version.errors[:vendor].should_not be_nil
      end

      it "should allow you to upload vendors if your an admin" do
        other_user.stub(:admin?).and_return true
        version = VendorKit::Version.new(:user => other_user, :vendor_spec => new_vendor_spec)

        version.save.should be_true
      end

      it 'should overwrite atributes on the existing vendor' do
        version = VendorKit::Version.new(:user => user, :vendor_spec => new_vendor_spec)
        version.save

        version.vendor.authors.should == [ "keithpitt", "mariovisic" ]
        version.vendor.homepage.should == "http://www.mariovisic.com"
        version.vendor.source.should == "https://github.com/mariovisic/DKBenchmark"
        version.vendor.description.should == "Easy benchmarking with cheese"
        version.vendor.email.should == "mario@mariovisic.com"
      end

      it 'should increase the version count on the verndors versions' do
        expect do
          VendorKit::Version.create(:user => user, :vendor_spec => new_vendor_spec)
        end.to change(existing.vendor.versions, :count).by(1)
      end

      it "should not allow you upload an existing version" do
        version = VendorKit::Version.new(:user => user, :vendor_spec => existing_vendor_spec)

        version.save.should be_false
        version.errors[:vendor].should_not be_nil
      end

      it "should only update the vendor attributes if the new version record has a higher number than the current version" do
        existing.vendor.release.version.to_s.should == "0.1"
        version = VendorKit::Version.new(:user => user, :vendor_spec => newer_vendor_spec)
        version.save
        version.reload

        version.vendor.description.should == "Easy benchmarking with cheese AND BACON!"
        version.vendor.release.version.to_s.should == "0.2.1"
      end

      it "should not update vendor attributes if the version you push is older than the current one" do
        version = VendorKit::Version.new(:user => user, :vendor_spec => old_vendor_spec)
        version.save
        version.reload

        version.vendor.description.should_not == "THIS IS THE OLD ONE!!"
      end

    end

    context "with a new vendor" do

      let!(:version) { VendorKit::Version.create(:user => user, :vendor_spec => existing_vendor_spec) }

      it "should create a vendor" do
        version.vendor.name.should == "DKBenchmark"
      end

      it "should set the authors for the vendor" do
        version.vendor.authors.should == [ "keithpitt" ]
      end

      it "should set the homepage for the vendor" do
        version.vendor.homepage.should == "http://www.keithpitt.com"
      end

      it "should set the source link for the vendor" do
        version.vendor.source.should == "https://github.com/keithpitt/DKBenchmark"
      end

      it "should set the contact email for the vendor" do
        version.vendor.email.should == "me@keithpitt.com"
      end

      it "should set the vendor spec" do
        version.vendor_spec.should == HashWithIndifferentAccess.new(existing_vendor_spec)
      end

    end

  end

end
