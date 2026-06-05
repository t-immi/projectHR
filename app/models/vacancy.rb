class Vacancy < ApplicationRecord
  SOURCES = %w[upload hh].freeze

  belongs_to :user, optional: true

  has_many :match_scores, dependent: :destroy
  has_many :resumes, through: :match_scores

  validates :title, presence: true
  validates :body, presence: true
  validates :source, presence: true, inclusion: { in: SOURCES }
  validates :hh_external_id, uniqueness: true, allow_nil: true

  scope :from_upload, -> { where(source: "upload") }
  scope :from_hh, -> { where(source: "hh") }
  scope :recent, -> { order(created_at: :desc) }

  def self.find_or_create_from_hh!(attributes)
    find_or_create_by!(hh_external_id: attributes[:hh_external_id]) do |vacancy|
      vacancy.title = attributes[:title]
      vacancy.body = attributes[:body]
      vacancy.source = "hh"
    end
  end

  def uploaded_resumes_with_scores
    match_scores
      .joins(:resume)
      .where(resumes: { source: "upload" })
      .includes(:resume)
      .merge(MatchScore.by_score_desc)
  end
end
