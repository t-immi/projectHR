require "rails_helper"

RSpec.describe Resume, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:match_scores).dependent(:destroy) }
    it { is_expected.to have_many(:vacancies).through(:match_scores) }
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(build(:resume)).to be_valid
    end

    it "requires title" do
      expect(build(:resume, title: nil)).not_to be_valid
    end

    it "requires allowed source" do
      expect(build(:resume, source: "invalid")).not_to be_valid
    end
  end

  describe ".from_hh" do
    it "returns only hh resumes" do
      hh_resume = create(:resume, :from_hh)
      create(:resume)

      expect(described_class.from_hh).to contain_exactly(hh_resume)
    end
  end

  describe ".find_or_create_from_hh!" do
    it "creates a resume from hh attributes" do
      resume = described_class.find_or_create_from_hh!(
        hh_external_id: "hh-1",
        title: "Developer",
        body: "Skills"
      )

      expect(resume).to be_persisted
      expect(resume.source).to eq("hh")
    end
  end
end
