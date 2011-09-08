class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login

  validates :username, :uniqueness => true, :presence => true

  before_save :ensure_authentication_token

  has_many :vendors
  has_many :versions

  protected

    def self.find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      login = conditions.delete(:login)

      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    end

    def self.find_recoverable_or_initialize_with_errors(required_attributes, attributes, error=:invalid)
      (case_insensitive_keys || []).each { |k| attributes[k].try(:downcase!) }

      attributes = attributes.slice(*required_attributes)
      attributes.delete_if { |key, value| value.blank? }

      if attributes.size == required_attributes.size
        if attributes.has_key?(:login)
          login = attributes.delete(:login)
          record = find_record(login)
        else
          record = where(attributes).first
        end
      end

      unless record
        record = new
        required_attributes.each do |key|
          value = attributes[key]
          record.send("#{key}=", value)
          record.errors.add(key, value.present? ? error : :blank)
        end
      end

      record
    end

    def self.find_record(login)
      where(["username = :value OR email = :value", { :value => login }]).first
    end

end
