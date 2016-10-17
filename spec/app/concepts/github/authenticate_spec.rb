require "rails_helper"
require "./spec/fixtures/mock_auth"

describe Github::Authenticate do

  subject { described_class.(auth) }

  let(:auth) { MockAuth.new }

  context "with valid data" do

    subject { super().model }

    let(:provider)      { "github" }
    let(:uid)           { "12345" }
    let(:email_address) { "foo@bar.com" }
    let(:token)         { SecureRandom.hex }
    let(:auth) do
      MockAuth.new(
        provider: provider,
        uid:      uid,
        email:    email_address,
        token:    token
      )
    end

    its(:provider) { is_expected.to eq(provider) }
    its(:uid)      { is_expected.to eq(uid) }
    its(:email)    { is_expected.to eq(email_address) }
    its(:password) { is_expected.to be_a(String) }

    context "when the user does not yet exist" do
      it "persists that user" do
        expect { subject }.to change{ User.count }.by(1)
      end
    end

    context "when the user already exists" do
      let(:old_auth) do
        MockAuth.new(
          provider: provider,
          uid:      uid,
          email:    email_address,
          token:    SecureRandom.hex
        )
      end

      before :each do
        described_class.(old_auth)
      end

      it "does not create another user" do
        expect { subject }.not_to change{ User.count }
      end

      it "refreshes their github oauth token" do
        expect(subject.github_oauth_token).to eq(token)
      end
    end

    it "stores a github oauth token" do
      expect(subject.github_oauth_token).to eq(token)
    end

  end

  context "with invalid data" do
    subject { described_class.run(auth) }

    let(:auth) { MockAuth.new(provider: "", uid: "", email: "", token: "") }

    it "returns an invalid operation" do
      result, _ = subject

      expect(result).to be(false)
    end
  end

end
