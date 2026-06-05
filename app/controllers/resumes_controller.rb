class ResumesController < ApplicationController
  before_action :set_resume, only: %i[show hh_vacancies]

  def index
    @resumes = Resume.recent
  end

  def show
    @uploaded_match_scores = @resume.uploaded_vacancies_with_scores
    @hh_match_scores = @resume.hh_vacancies_with_scores
  end

  def new
    @resume = Resume.new
  end

  def create
    @resume = Resume.new(resume_params)
    @resume.source = "upload"

    if @resume.save
      compute_matches_for_all_vacancies(@resume)
      redirect_to @resume, notice: t("flash.resumes.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def hh_vacancies
    query = params[:text].presence || @resume.title
    @hh_match_scores = HhVacancySearchService.new(resume: @resume, query: query).call

    respond_to do |format|
      format.html { redirect_to @resume, notice: t("flash.resumes.hh_search_done", query: query) }
      format.json { render json: serialize_hh_results(@hh_match_scores, query: query) }
    end
  rescue HhRuClient::ApiError => e
    respond_to do |format|
      format.html do
        redirect_to @resume, alert: t("flash.resumes.hh_search_failed", message: e.message)
      end
      format.json { render json: { error: e.message }, status: :unprocessable_entity }
    end
  end

  private

  def set_resume
    @resume = Resume.find(params[:id])
  end

  def resume_params
    params.require(:resume).permit(:title, :body)
  end

  def compute_matches_for_all_vacancies(resume)
    Vacancy.from_upload.find_each do |vacancy|
      MatchScoreService.compute(resume: resume, vacancy: vacancy)
    end
  end

  def serialize_hh_results(match_scores, query:)
    {
      resume_id: @resume.id,
      query: query,
      items: MatchScoreSerializer.for_vacancy(match_scores)
    }
  end
end
