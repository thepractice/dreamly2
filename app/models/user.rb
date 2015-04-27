class User < ActiveRecord::Base
  serialize :word_freq, Hash
  serialize :word_freq_public, Hash
  serialize :hash_freq, Hash
  serialize :hash_freq_public, Hash

  has_many :dreams, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :screennames, dependent: :destroy

  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  acts_as_voter
  acts_as_messageable

  has_attached_file :avatar, :styles => { :large => "200x200#", :medium => "70x70#", :thumb => "48x48#" }, :default_url => "/images/:style/missing.jpeg"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login

  validates :username, presence: true, uniqueness: { case_sensitive: false }, format: { without: /\s/ }
  validates :name, presence: true

  include PgSearch
  multisearchable against: [:username, :name, :email, :graph_public]  

  #before_save :check_if_new
  after_create :send_welcome_message

  alias :devise_valid_password? :valid_password?

  # Allows for old jhad passwords
  def valid_password?(password)
    begin
      super(password)
    rescue BCrypt::Errors::InvalidHash
      return false unless Digest::SHA256.hexdigest(password) == encrypted_password
      logger.info "User #{email} is using the old password hashing method, updating attribute."
      self.password = password
      true
    end
  end

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
      elsif user.provider == 'facebook'
        user.username = auth.info.first_name + '.' + auth.info.last_name
        user.name = auth.info.name
        user.email = auth.info.email
      elsif user.provider == 'google_oauth2'
        user.username = auth.info.first_name + '.' + auth.info.last_name
        user.name = auth.info.name
        user.email = auth.info.email      
      else  # yahoo
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

  # Follows a user
  def follow(other_user)
    self.active_relationships.create(followed_id: other_user.id)
    Notification.create(user: other_user, other_user_id: self.id, subject: 'follow')
  end

  # Unfollows a user
  def unfollow(other_user)
    self.active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # Returns true if the current user is following the other user
  def following?(other_user)
    self.following.include?(other_user)
  end

  # Returns a user's status feed
  def feed
    Dream.from_users_followed_by(self)
  end

  # For Mailboxer
  def mailboxer_email(object)
    if object.class==Mailboxer::Notification
      return nil
    else
      self.email
    end
  end

  #def check_if_new
  #  @is_new_record = self.new_record?
  #end

  def send_welcome_message

    User.find_by(username: 'dreamly').send_message(self, "Welcome to the Collective Unconscious. Welcome to Dreamly.

We invite you to participate in our social experiment. We invite you to find yourself through others.

Dreamly is a social dream journal designed to help you better understand yourself, particularly on an unconscious level. Having the functionality to post and keep track of your dreams on a private and personal level, as well as interact publically with other users through dream comparison and messaging features, Dreamly is a uniquely designed platform aiming to cut through the illusion.

Social Media, up to this point, has been a testament to the exterior self. Innovations of our generation like Facebook and Twitter have allowed us to express the physical conceptions of ourselves to the online community. Whether a quick selfie or an elaborately constructed status post, . But what about the matter beneath the surface? What about the underlying layers of the psyche not receiving attention—the core emotional and psychological desires for wellbeing sewn deeply within the self?

Here at Dreamly we are looking to change the model of social media. We are looking in a different direction. We are looking inward. We are seeking to lift the veil once and for all by bringing together the Collective Unconscious—the inner connection that us humans intimately share.

Dreamly is in its alpha stages. We have a vision, but we are looking to better shape that vision using your input.

That’s why we need your voice.

We’re not asking for you to complete a hundred-question survey or to fill out a form with all of your demographical information. We want your feedback in your own words. We might throw one or two questions in to help guide us in our way, but what we really want is to hear exactly what you think of the site as is, and, any additional features that would improve your experience. Give us feedback by going to the <a href='http://community.dreamly.io'>Dreamly Community forums</a>.

We hope you enjoy your experience here at Dreamly.io. We look forward hearing from you.

Pleasant Dreaming,

The Dreamly Team", "Welcome message")
    self.notify('Message', 'You received a message')
    
  end

end
