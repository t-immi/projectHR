require "rails_helper"

RSpec.describe HhVacancySearchService do
  let(:resume) { create(:resume, title: "Ruby on Rails developer") }

  around do |example|
    original_ml = ENV["ML_STUB"]
    original_hh = ENV["HH_MOCK"]
    ENV["ML_STUB"] = "true"
    ENV["HH_MOCK"] = "true"
    example.run
    ENV["ML_STUB"] = original_ml
    ENV["HH_MOCK"] = original_hh
  end

  it "creates hh vacancies and match scores" do
    expect {
      described_class.new(resume: resume).call
    }.to change(Vacancy.from_hh, :count).by(5)
      .and change(MatchScore, :count).by(5)
  end

  it "uses custom query" do
    match_scores = described_class.new(resume: resume, query: "Python backend").call
    expect(match_scores.first.vacancy.title).to include("Python backend")
  end
end
