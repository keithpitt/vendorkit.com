module VendorForge
  class Version < ActiveRecord::Base

    require 'zip/zipfilesystem'

    class MissingVendorSpec < StandardError; end
    class InvalidVendorSpec < StandardError; end

    serialize :vendor_spec

    mount_uploader :package, PackageUploader

    belongs_to :vendor
    belongs_to :user

    has_many :dependencies

    validates :number, :presence => true
    validates :user, :presence => true

    before_validation :extract_vendor_spec, :if => :package_changed?
    before_validation :update_from_vendor_spec, :if => :vendor_spec_changed?
    before_save :update_dependencies, :if => :vendor_spec_changed?

    def version
      ::Vendor::Version.new(number)
    end

    def vendor_spec=(value)
      super HashWithIndifferentAccess.new(value)
    end

    private

    def extract_vendor_spec
      if package.present?
        begin
          Zip::ZipFile.open(package.current_path) do |zipfile|
            begin
              json = zipfile.file.read("vendor.json")
            rescue
              raise MissingVendorSpec.new
            end

            spec = JSON.parse(json)
            raise InvalidVendorSpec.new unless spec.present?

            self.vendor_spec = spec
          end
        rescue MissingVendorSpec => e
          errors.add(:package, :missing_spec)
        rescue InvalidVendorSpec => e
          errors.add(:package, :invalid_spec)
        end
      end
    end

    def update_from_vendor_spec
      spec = HashWithIndifferentAccess.new(vendor_spec)
      existing = VendorForge::Vendor.where(:name => vendor_spec[:name]).first

      if existing.present?
        if existing.user == user
          if existing.versions.where(:number => vendor_spec[:version]).exists?
            errors.add :number, :existing_version
            return false
          else
            self.vendor = existing
          end
        else
          errors.add :vendor, :permission_denied
          return false
        end
      else
        self.vendor = VendorForge::Vendor.new(:name => vendor_spec[:name], :user => user)
      end

      [ :email, :homepage, :description, :authors, :source, :docs ].each do |attr|
        vendor.send("#{attr}=", vendor_spec[attr])
      end

      self.number = vendor_spec[:version]
    end

    def update_dependencies

      # Remove all existing dependencies
      dependencies.destroy_all

      # Store the library dependencies
      if vendor_spec[:dependencies]
        vendor_spec[:dependencies].each do |d|
          dependencies.build :name => d[0], :number => d[1]
        end
      end

    end

  end
end