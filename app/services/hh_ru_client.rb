class HhRuClient
  API_BASE = "https://api.hh.ru".freeze

  class ApiError < StandardError; end

  def search_vacancies(text:, per_page: 5)
    if mock_mode?
      return mock_vacancies(text: text, per_page: per_page)
    end

    cache_key = "hh_vacancies:#{Digest::SHA256.hexdigest(text)}:#{per_page}"
    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      response = connection.get("#{API_BASE}/vacancies") do |req|
        req.headers["User-Agent"] = user_agent
        req.params["text"] = text
        req.params["per_page"] = per_page
      end

      raise ApiError, "Vacancy search failed: #{response.status}" unless response.success?

      JSON.parse(response.body)
    end
  end

  private

  def mock_mode?
    ENV.fetch("HH_MOCK", "true") == "true"
  end

  def mock_vacancies(text:, per_page:)
    fixture_path = Rails.root.join("spec/fixtures/hh_vacancies.json")
    data = JSON.parse(File.read(fixture_path))
    items = data["items"].first(per_page).map do |item|
      item.merge(
        "name" => item["name"].gsub("{{query}}", text),
        "snippet" => {
          "requirement" => item.dig("snippet", "requirement")&.gsub("{{query}}", text),
          "responsibility" => item.dig("snippet", "responsibility")
        }
      )
    end
    data.merge("items" => items, "found" => items.size)
  end

  def user_agent
    ENV.fetch("HH_USER_AGENT", "HRMatcher/1.0 (student@example.com)")
  end

  def connection
    @connection ||= Faraday.new do |f|
      f.options.timeout = 15
      f.options.open_timeout = 5
    end
  end
end
