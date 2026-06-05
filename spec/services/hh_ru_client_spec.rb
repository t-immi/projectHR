require "rails_helper"

RSpec.describe HhRuClient do
  around do |example|
    original = ENV["HH_MOCK"]
    ENV["HH_MOCK"] = "true"
    example.run
    ENV["HH_MOCK"] = original
  end

  describe "#search_vacancies" do
    it "returns mock vacancies with substituted query" do
      result = described_class.new.search_vacancies(text: "Rails developer", per_page: 2)

      expect(result["items"].size).to eq(2)
      expect(result["items"].first["name"]).to include("Rails developer")
    end
  end
end
