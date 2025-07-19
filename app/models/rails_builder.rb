class RailsBuilder < ApplicationRecord
  # 🚅 add concerns above.

  attr_accessor :bio_image_removal
  # 🚅 add attribute accessors above.

  belongs_to :team
  belongs_to :builder_level, optional: true
  # 🚅 add belongs_to associations above.

  has_many :participations, dependent: :destroy
  # 🚅 add has_many associations above.

  has_one_attached :bio_image
  # 🚅 add has_one associations above.

  # JSON accessors for details column
  store_accessor :details, :focusing_on, :ai_setup, :needs, :offers, :running_on, :personal_quote, :community_comment

  # 🚅 add scopes above.

  validates :first_name, presence: true
  validates :email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :builder_level, scope: true
  # 🚅 add validations above.

  after_validation :remove_bio_image, if: :bio_image_removal?
  # 🚅 add callbacks above.

  # 🚅 add delegations above.

  def valid_builder_levels
    BuilderLevel.all
  end

  def bio_image_removal?
    bio_image_removal.present?
  end

  def remove_bio_image
    bio_image.purge
  end

  # 🚅 add methods above.
end
