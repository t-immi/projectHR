class MatchScoresController < ApplicationController
  def index
    @match_scores = MatchScore.includes(:resume, :vacancy).by_score_desc
  end
end
