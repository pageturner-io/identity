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
    let(:auth) do
      MockAuth.new(
        provider: provider,
        uid:      uid,
        email:    email_address
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
      before :each do
        subject
      end

      it "does not create another user" do
        expect { subject }.not_to change{ User.count }
      end
    end

  end

  context "with invalid data" do
    subject { described_class.run(auth) }

    let(:auth) { MockAuth.new(provider: "", uid: "", email: "") }

    it "returns an invalid operation" do
      result, _ = subject

      expect(result).to be(false)
    end
  end

end
