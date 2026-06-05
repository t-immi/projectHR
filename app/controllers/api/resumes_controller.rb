module Api
  class ResumesController < ApplicationController
    def hh_vacancies
      resume = Resume.find(params[:id])
      query = params[:text].presence || resume.title
      match_scores = HhVacancySearchService.new(resume: resume, query: query).call

      render json: {
        resume_id: resume.id,
        query: query,
        items: MatchScoreSerializer.for_vacancy(match_scores)
      }
    rescue HhRuClient::ApiError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end
