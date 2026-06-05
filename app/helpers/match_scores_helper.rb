module MatchScoresHelper
  def match_score_badge(match_score)
    level = match_score.match_level
    css_class = case level
                when "high" then "bg-success"
                when "medium" then "bg-warning text-dark"
                else "bg-secondary"
                end

    tag.span("#{match_score.score_percent}%", class: "badge #{css_class}")
  end
end
