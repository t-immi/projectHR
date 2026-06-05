require "rails_helper"

RSpec.describe MatchScoreService do
  let(:resume) { create(:resume) }
  let(:vacancy) { create(:vacancy) }

  around do |example|
    original = ENV["ML_STUB"]
    ENV["ML_STUB"] = "true"
    example.run
    ENV["ML_STUB"] = original
  end

  describe ".compute" do
    it "creates a match score" do
      expect {
        described_class.compute(resume: resume, vacancy: vacancy)
      }.to change(MatchScore, :count).by(1)
    end

    it "updates an existing match score" do
      existing = described_class.compute(resume: resume, vacancy: vacancy)

      expect {
        described_class.compute(resume: resume, vacancy: vacancy)
      }.not_to change(MatchScore, :count)

      expect(existing.reload.score).to be_between(0, 1)
    end
  end

  context "when ML API is used" do
    before do
      ENV["ML_STUB"] = "false"
      ENV["ML_SERVICE_URL"] = "http://ml.local"
      stub_request(:post, "http://ml.local/predict")
        .to_return(status: 200, body: { score: 0.91 }.to_json, headers: { "Content-Type" => "application/json" })
    end

    it "stores score from ML service" do
      match_score = described_class.compute(resume: resume, vacancy: vacancy)
      expect(match_score.score).to eq(0.91)
    end
  end
end
