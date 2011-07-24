class User
  include Mongoid::Document
  include Mongo::Voter
  include Mongoid::Timestamps
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable, :timeoutable, :confirmable and :activatable, :rpx_connectable, :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  field :campuser

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :campuser

  validates_presence_of :email, :password, :campuser
  validates_uniqueness_of :email, :case_sensitive => false

  references_one  :person
  references_many :posts

  #after_create :seed_aspects
  #before_destroy :disconnect_everyone, :remove_person

  before_save do
    #debugger
    person.save if person
    #person.save!
  end

  def strip_and_downcase_campuser
    if campuser.present?
      campuser.strip!
      campuser.downcase!
    end
  end

  #def set_current_language
    #self.language = I18n.locale.to_s if self.language.blank?
  #end

  def method_missing(method, *args)
    self.person.send(method, *args) if self.person
  end

  ###Helpers############
  def self.build(opts = {})
    #debugger
    u = User.new(opts)
    u.email = opts[:email]
    u.setup(opts)
    u
  end

  def setup(opts)
    self.campuser = opts[:campuser]
    self.valid?
    errors = self.errors
    errors.delete :person
    return if errors.size > 0

    opts[:person] ||= {}
    #opts[:person][:profile] ||= Profile.new

    self.person = Person.new(opts[:person])
    #self.person.diaspora_handle = "#{opts[:username]}@#{APP_CONFIG[:pod_uri].host}"
    #self.person.url = APP_CONFIG[:pod_url]

    self.person.campuser = opts[:campuser]
    #self.serialized_private_key ||= User.generate_key
    #self.person.serialized_public_key = OpenSSL::PKey::RSA.new(self.serialized_private_key).public_key

    self
  end

end
