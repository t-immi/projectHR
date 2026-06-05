class HhVacancySearchService
  DEFAULT_PER_PAGE = 5

  def initialize(resume:, query: nil, per_page: DEFAULT_PER_PAGE)
    @resume = resume
    @query = query.presence || resume.title
    @per_page = per_page
    @client = HhRuClient.new
  end

  def call
    response = @client.search_vacancies(text: @query, per_page: @per_page)
    items = response.fetch("items", []).first(@per_page)

    items.map do |item|
      vacancy = Vacancy.find_or_create_from_hh!(
        hh_external_id: item["id"].to_s,
        title: item["name"],
        body: build_body(item)
      )
      MatchScoreService.compute(resume: @resume, vacancy: vacancy)
    end
  end

  private

  def build_body(item)
    parts = [
      item["name"],
      item.dig("employer", "name") && "Компания: #{item.dig('employer', 'name')}",
      item.dig("area", "name") && "Город: #{item.dig('area', 'name')}",
      format_salary(item["salary"]),
      item.dig("snippet", "requirement"),
      item.dig("snippet", "responsibility")
    ].compact

    parts.join("\n\n")
  end

  def format_salary(salary)
    return if salary.blank?

    from = salary["from"]
    to = salary["to"]
    currency = salary["currency"] || "RUR"

    range = [from, to].compact.join(" – ")
    "Зарплата: #{range} #{currency}"
  end
end
