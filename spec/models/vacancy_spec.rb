require "rails_helper"

RSpec.describe Vacancy, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:match_scores).dependent(:destroy) }
    it { is_expected.to have_many(:resumes).through(:match_scores) }
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:vacancy)).to be_valid
    end

    it "requires title" do
      expect(build(:vacancy, title: nil)).not_to be_valid
    end
  end
end
