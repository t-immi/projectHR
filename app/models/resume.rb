class Resume < ApplicationRecord
  SOURCES = %w[upload hh].freeze

  belongs_to :user, optional: true

  has_many :match_scores, dependent: :destroy
  has_many :vacancies, through: :match_scores

  validates :title, presence: true
  validates :body, presence: true
  validates :source, presence: true, inclusion: { in: SOURCES }
  validates :hh_external_id, uniqueness: true, allow_nil: true

  scope :from_upload, -> { where(source: "upload") }
  scope :from_hh, -> { where(source: "hh") }
  scope :recent, -> { order(created_at: :desc) }

  def self.find_or_create_from_hh!(attributes)
    find_or_create_by!(hh_external_id: attributes[:hh_external_id]) do |resume|
      resume.title = attributes[:title]
      resume.body = attributes[:body]
      resume.source = "hh"
    end
  end

  def uploaded_vacancies_with_scores
    match_scores
      .joins(:vacancy)
      .where(vacancies: { source: "upload" })
      .includes(:vacancy)
      .merge(MatchScore.by_score_desc)
  end

  def hh_vacancies_with_scores
    match_scores
      .joins(:vacancy)
      .where(vacancies: { source: "hh" })
      .includes(:vacancy)
      .merge(MatchScore.by_score_desc)
  end
end
