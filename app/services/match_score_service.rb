class MatchScoreService
  class PredictionError < StandardError; end

  def self.compute(resume:, vacancy:)
    new(resume: resume, vacancy: vacancy).compute
  end

  def initialize(resume:, vacancy:)
    @resume = resume
    @vacancy = vacancy
  end

  def compute
    score = fetch_score
    match_score = MatchScore.find_or_initialize_by(resume: @resume, vacancy: @vacancy)
    match_score.score = score
    match_score.computed_by = "ml_model"
    match_score.save!
    match_score
  end

  private

  def fetch_score
    if stub_mode?
      stub_score
    else
      api_score
    end
  end

  def stub_mode?
    ENV.fetch("ML_STUB", "false") == "true"
  end

  def stub_score
    digest = Digest::SHA256.hexdigest("#{@resume.body}::#{@vacancy.body}")
    (digest.to_i(16) % 10_000) / 10_000.0
  end

  def api_score
    response = connection.post("/predict") do |req|
      req.headers["Content-Type"] = "application/json"
      req.body = {
        resume_text: @resume.body,
        vacancy_text: @vacancy.body
      }.to_json
    end

    raise PredictionError, "ML service error: #{response.status}" unless response.success?

    body = JSON.parse(response.body)
    score = body["score"].to_f
    raise PredictionError, "Invalid score from ML service" unless score.between?(0, 1)

    score
  rescue Faraday::Error => e
    raise PredictionError, "ML service unavailable: #{e.message}"
  end

  def connection
    @connection ||= Faraday.new(url: ENV.fetch("ML_SERVICE_URL", "http://localhost:8000")) do |f|
      f.options.timeout = 30
      f.options.open_timeout = 5
    end
  end
end
