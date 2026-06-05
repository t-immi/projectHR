require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it "is valid with factory attributes" do
      expect(build(:user)).to be_valid
    end

    it "requires unique hh_id" do
      create(:user, hh_id: "same-id")
      expect(build(:user, hh_id: "same-id")).not_to be_valid
    end
  end

  describe "#token_valid?" do
    it "returns true when token is present and not expired" do
      expect(build(:user, expires_at: 1.hour.from_now)).to be_token_valid
    end

    it "returns false when token expired" do
      expect(build(:user, expires_at: 1.hour.ago)).not_to be_token_valid
    end
  end

  describe "#display_name" do
    it "prefers name" do
      expect(build(:user, name: "Ivan", email: "a@b.c").display_name).to eq("Ivan")
    end
  end
end
