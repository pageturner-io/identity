require "rails_helper"

describe "Authentication with Github" do

  subject do
    get "/auth/auth/github/callback", params: {
      code: SecureRandom.hex, state: SecureRandom.hex
    }
  end

  before :each do
    Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:github]
  end

  it "signs the user in" do
    subject

    expect(@controller.current_user).not_to be_nil
  end

  it "redirects the user to the home page" do
    expect(subject).to redirect_to("/")
  end

end
