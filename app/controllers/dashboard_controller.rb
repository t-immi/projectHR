class DashboardController < ApplicationController
  def index
    @resumes_count = Resume.count
    @vacancies_count = Vacancy.count
    @match_scores_count = MatchScore.count
    @recent_match_scores = MatchScore.includes(:resume, :vacancy).recent.limit(10)
    @recent_vacancies = Vacancy.recent.limit(5)
    @recent_resumes = Resume.recent.limit(5)
  end
end
