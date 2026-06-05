class MatchScore < ApplicationRecord
  belongs_to :resume
  belongs_to :vacancy

  validates :score, presence: true,
                    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :computed_by, presence: true
  validates :resume_id, uniqueness: { scope: :vacancy_id }

  scope :by_score_desc, -> { order(score: :desc) }
  scope :recent, -> { order(created_at: :desc) }

  def score_percent
    (score * 100).round(1)
  end

  def match_level
    case score
    when 0.7.. then "high"
    when 0.4...0.7 then "medium"
    else "low"
    end
  end
end
