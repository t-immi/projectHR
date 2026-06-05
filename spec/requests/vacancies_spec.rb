require "rails_helper"

RSpec.describe "Vacancies", type: :request do
  around do |example|
    original_ml = ENV["ML_STUB"]
    ENV["ML_STUB"] = "true"
    example.run
    ENV["ML_STUB"] = original_ml
  end

  describe "POST /vacancies" do
    it "creates a vacancy and match scores" do
      create(:resume)

      expect {
        post vacancies_path, params: {
          vacancy: { title: "Rails dev", body: "Backend development" }
        }
      }.to change(Vacancy, :count).by(1)
        .and change(MatchScore, :count).by(1)

      expect(response).to redirect_to(Vacancy.last)
    end
  end
end
