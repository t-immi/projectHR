require "rails_helper"

RSpec.describe MatchScore, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:resume) }
    it { is_expected.to belong_to(:vacancy) }
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:match_score)).to be_valid
    end

    it "requires score between 0 and 1" do
      expect(build(:match_score, score: 1.5)).not_to be_valid
      expect(build(:match_score, score: -0.1)).not_to be_valid
    end

    it "validates uniqueness of resume per vacancy" do
      existing = create(:match_score)
      duplicate = build(:match_score, resume: existing.resume, vacancy: existing.vacancy)

      expect(duplicate).not_to be_valid
    end
  end

  describe "#match_level" do
    it "returns high for strong matches" do
      expect(build(:match_score, score: 0.8).match_level).to eq("high")
    end
  end
end
