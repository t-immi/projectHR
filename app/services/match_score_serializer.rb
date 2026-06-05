module MatchScoreSerializer
  module_function

  def for_vacancy(match_scores)
    match_scores.map do |match_score|
      {
        vacancy_id: match_score.vacancy_id,
        title: match_score.vacancy.title,
        source: match_score.vacancy.source,
        employer: extract_employer(match_score.vacancy.body),
        score: match_score.score.to_f,
        score_percent: match_score.score_percent,
        match_level: match_score.match_level
      }
    end
  end

  def for_resume(match_scores)
    match_scores.map do |match_score|
      {
        resume_id: match_score.resume_id,
        title: match_score.resume.title,
        source: match_score.resume.source,
        score: match_score.score.to_f,
        score_percent: match_score.score_percent,
        match_level: match_score.match_level
      }
    end
  end

  def extract_employer(body)
    body.to_s[/Компания: (.+)/, 1]
  end
end
