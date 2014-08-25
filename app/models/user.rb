class User < ActiveRecord::Base
  serialize :word_freq, Hash
  serialize :word_freq_public, Hash

  has_many :dreams, dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true

  # Method for Devise to use either username or email to login.
  # This is the correct method you override with the code below:
  # def self.find_for_database_authentication(warden_conditions)
  # end
  def self.find_first_by_auth_conditions(warden_conditions)
  	conditions = warden_conditions.dup
  	if login = conditions.delete(:login)
  		where(conditions).where(["lower(username) = :value OR lower(email) = :value", 
  														{ :value => login.downcase }]).first 
  	else
  		where(conditions).first
  	end
  end

  # Method for finding user from OmniAuth callback or creating that user.
  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      if user.provider == 'twitter'
        user.username = auth.info.nickname
        user.name = auth.info.name
      else
        user.username = auth.info.name
        user.name = auth.info.name
      end
    end
  end

  # Override Devise user class method. To handle OmniAuth callback failures, showing error
  # messages. Set the callback attributes back to user model to be validated at signup form.
  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      # create new user record based on OmniAuth callback details
      new(session["devise.user_attributes"], without_protection: true) do |user|
        # Set attributes again via params hash, which is attributes send by user through form
        user.attributes = params
        # Validate user to ensure display of validation errors
        user.valid?
      end
    else
      # Fall back to normal Devise behavior--creating a new user instance
      super
    end
  end

  # for Google oath2
 # def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
 #   data = access_token.info
 #   user = User.where(:email => data["email"]).first

    # Uncomment the section below if you want users to be created if they don't exist
    # unless user
    #     user = User.create(name: data["name"],
    #        email: data["email"],
    #        password: Devise.friendly_token[0,20]
    #     )
    # end
#    user
#  end


  # Override method on user model so that users using OmniAuth don't require password.
  def password_required?
    # Fall back to default behavior and ensure provider is blank.
    super && provider.blank?
  end

  def email_required?
    super && provider.blank?
  end

  # Override method so that OmniAuth users (without passwords) can update their info w/o passwords.
  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end
end
