class User < ActiveRecord::Base
  rolify role_join_table_name: 'roles_users'


  include Authority::UserAbilities
  include Authority::Abilities

  # Enable User Connection to External API Accounts
  include ExternalUsers

  # Map to PCORNET Common Data Model
  include CommonDataModel


  self.authorizer_name = "UserAuthorizer"

  # Include default devise modules. Others available are:
  # :confirmable, :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :timeoutable, :lockable

  # Model Validation
  validates_presence_of :first_name, :last_name, :year_of_birth
  validates_numericality_of :year_of_birth, allow_nil: false, only_integer: true, less_than_or_equal_to: -> (user){ Date.today.year - 18 }, greater_than_or_equal_to: -> (user){ 1900 }

  # Model Relationships
  has_many :answer_sessions
  has_many :answers
  has_many :votes
  has_one :social_profile
  has_many :notifications
  has_many :research_topics
  has_many :forums, -> { where(deleted: false) }
  has_many :topics, -> { where(deleted: false) }
  has_many :posts, -> { where(deleted: false) }

  # Named Scopes
  scope :search_by_email, ->(terms) { where("LOWER(#{self.table_name}.email) LIKE ?", terms.to_s.downcase.gsub(/^| |$/, '%')) }
  scope :current, -> { where('1 = 1') }

  def deleted?
    false
  end

  def all_topics
    if self.has_role? :moderator
      Topic.current
    else
      self.topics.where(locked: false)
    end
  end

  def viewable_topics
    if self.has_role? :moderator
      Topic.current
    else
      Topic.viewable_by_user(self.id)
    end
  end

  def all_posts
    if self.has_role? :moderator
      Post.current.with_unlocked_topic
    else
      self.posts.where(hidden: false).with_unlocked_topic
    end
  end

  def smart_forum
    forum_id = self.posts.group_by{|p| p.forum.id}.collect{|forum_id, posts| [forum_id, posts.count]}.sort{|a,b| b[1] <=> a[1]}.collect{|a| a[0]}.first
    forum = Forum.current.find_by_id(forum_id)
    forum ? forum : Forum.current.order(:position).first
  end

  def name
    "#{first_name} #{last_name}"
  end

  def self.scoped_users(email=nil, role=nil)
    users = all

    users = users.search_by_email(email) if email.present?
    users = users.with_role(role) if role.present?

    users
  end

  def photo_url
    if social_profile
      social_profile.photo_url
    else
      'default-user.jpg'
    end
  end

  def my_photo_url
    if social_profile and social_profile.photo
      social_profile.photo.url
    else
      photo_url
    end
  end

  def forum_name
    self.forem_name
  end

  def forem_name
    if social_profile
      social_profile.public_nickname
    else
      SocialProfile.get_anonymous_name(email)
    end
  end

  def to_s
    email
  end

  def revoke_consent
    update_attribute :accepted_consent_at, nil
    update_attribute :accepted_privacy_policy_at, nil
  end

  def created_social_profile?
    self.social_profile.present? and self.social_profile.name.present?
  end

  def signed_consent?
    # Local Consent Storage
    self.accepted_consent_at.present?
    # OODT Consent Storage
    #self.oodt_status
  end

  def accepted_privacy_policy?
    self.accepted_privacy_policy_at.present?

  end

  def accepted_terms_conditions?
    self.accepted_terms_conditions_at.present?
  end

  def ready_for_research?
    accepted_privacy_policy? and signed_consent?
  end

  def can_post_links?
    self.forem_admin?
  end

  def forem_admin?
    self.has_role? :admin
  end

  def can_create_forem_topics?(forum)
    self.can?(:participate_in_social)
  end

  def can_reply_to_forem_topic?(topic)
    self.can?(:participate_in_social)
  end

  def can_edit_forem_posts?(forum)
    self.can?(:participate_in_social)
  end

  def can_destroy_forem_posts?(forum)
    self.can?(:participate_in_social)
  end


  def can_moderate_forem_forum?(forum)
    self.has_role? :forum_moderator or self.has_role? :admin
  end

  def todays_votes
    votes.select{|vote| vote.updated_at.today? and vote.rating != 0 and vote.research_topic_id.present?}
  end

  def available_votes_percent
    (todays_votes.length.to_f / vote_quota) * 100.0
  end

  def is_owner?
    self.has_role? :owner
  end

  def is_admin?
    self.has_role? :admin or is_owner?
  end

  def is_moderator?
    self.has_role? :moderator or is_admin?
  end

  def incomplete_surveys
    QuestionFlow.incomplete(self)
  end

  def complete_surveys
    QuestionFlow.complete(self)
  end

  def unstarted_surveys
    QuestionFlow.unstarted(self)
  end

  def smart_surveys
    self.incomplete_surveys + self.unstarted_surveys + self.complete_surveys
  end

  def research_topics_with_vote
    ResearchTopic.voted_by(self)
  end

  def submitted_research_topics
    ResearchTopic.created_by(self)
  end

  def has_no_started_surveys?
    incomplete_surveys.blank? and complete_surveys.blank?
  end

  def share_research_topics?
    social_profile.present? and social_profile.show_publicly?
  end

  def has_votes_remaining?(rating = 1)

    (todays_votes.length < vote_quota) or (rating < 1)
  end

  def answer_for(answer_session, question)
    Answer.where(answer_session_id: answer_session.id, question_id: question.id).order("updated_at desc").includes(answer_values: :answer_template).limit(1).first
  end
end
