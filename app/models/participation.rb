class Participation < ApplicationRecord
  belongs_to :rails_builder

  validates :started_at, presence: true

  scope :active, -> { where(left_at: nil) }
  scope :past, -> { where.not(left_at: nil) }
end
