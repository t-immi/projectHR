class VacanciesController < ApplicationController
  before_action :set_vacancy, only: %i[show compute_matches]

  def index
    @vacancies = Vacancy.recent
  end

  def show
    @uploaded_match_scores = @vacancy.uploaded_resumes_with_scores
  end

  def new
    @vacancy = Vacancy.new
  end

  def create
    @vacancy = Vacancy.new(vacancy_params)
    @vacancy.source = "upload"

    if @vacancy.save
      compute_matches_for_all_resumes(@vacancy)
      redirect_to @vacancy, notice: t("flash.vacancies.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def compute_matches
    Resume.from_upload.find_each do |resume|
      MatchScoreService.compute(resume: resume, vacancy: @vacancy)
    end

    redirect_to @vacancy, notice: t("flash.vacancies.matches_computed")
  end

  private

  def set_vacancy
    @vacancy = Vacancy.find(params[:id])
  end

  def vacancy_params
    params.require(:vacancy).permit(:title, :body)
  end

  def compute_matches_for_all_resumes(vacancy)
    Resume.from_upload.find_each do |resume|
      MatchScoreService.compute(resume: resume, vacancy: vacancy)
    end
  end
end
