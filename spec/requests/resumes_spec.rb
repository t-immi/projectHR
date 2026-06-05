require "rails_helper"

RSpec.describe "Resumes", type: :request do
  around do |example|
    original = ENV["ML_STUB"]
    ENV["ML_STUB"] = "true"
    example.run
    ENV["ML_STUB"] = original
  end

  describe "POST /resumes" do
    it "creates a resume and redirects" do
      vacancy = create(:vacancy)

      expect {
        post resumes_path, params: {
          resume: { title: "Backend dev", body: "Rails, PostgreSQL" }
        }
      }.to change(Resume, :count).by(1)
        .and change(MatchScore, :count).by(1)

      expect(response).to redirect_to(Resume.last)
      expect(MatchScore.last.vacancy).to eq(vacancy)
    end
  end

  describe "GET /api/resumes/:id/hh_vacancies" do
    around do |example|
      original_hh = ENV["HH_MOCK"]
      ENV["HH_MOCK"] = "true"
      example.run
      ENV["HH_MOCK"] = original_hh
    end

    it "returns hh vacancies with scores as json" do
      resume = create(:resume, title: "Ruby developer")

      get hh_vacancies_api_resume_path(resume), params: { text: "Ruby developer" },
          headers: { "ACCEPT" => "application/json" }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["items"].size).to eq(5)
      expect(body["query"]).to eq("Ruby developer")
      expect(body["items"].first).to include("score_percent", "title")
    end
  end
end
