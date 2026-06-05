require "rails_helper"

RSpec.describe HhRuClient do
  describe "#search_vacancies" do
    around do |example|
      original = ENV["HH_MOCK"]
      ENV["HH_MOCK"] = "true"
      example.run
      ENV["HH_MOCK"] = original
    end

    it "returns five mock vacancies" do
      result = described_class.new.search_vacancies(text: "Rails", per_page: 5)

      expect(result["items"].size).to eq(5)
      expect(result["items"].first["name"]).to include("Rails")
    end
  end
end
