require "rails_helper"

describe "Authentication with Github"do

  subject do
    get "/auth/auth/github/callback", params: {
      code: SecureRandom.hex,
      state: SecureRandom.hex
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

  describe "the authentication cookie", type: :feature  do
    subject { get_me_the_cookie("user.session") }

    let(:user) { User.find_by_uid(ENV["USER_UID"]) }
    let(:jwt) do
      JWTWrapper.encode(
        id:                 user.id,
        github_oauth_token: user.github_oauth_token
      )
    end
    let(:expiration_date) do
      Rails.application.secrets.jwt_expiration_hours.hours.from_now.gmtime.
          strftime("%a, %d-%b-%Y %H:%M:%S GMT")
    end

    before :each do
      Timecop.freeze
      visit "/auth/auth/github/callback?code=#{SecureRandom.hex}&state=#{SecureRandom.hex}"
    end

    after :each do
      Timecop.return
    end

    its([:domain])   { is_expected.to eq(ENV["SSO_DOMAIN"]) }
    its([:expires])  { is_expected.to eq(expiration_date) }
    its([:httponly]) { is_expected.to be(true) }
    its([:value])    { is_expected.to eq(jwt) }
  end

end
