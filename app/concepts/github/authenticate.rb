module Github
  class Authenticate < Trailblazer::Operation

    contract do
      property :provider
      property :uid
      property :email
      property :password

      validation do
        required(:provider).filled
        required(:uid).filled
        required(:email).filled
        required(:password).filled
      end
    end

    def process(params)
      validate(params) do
        contract.save
      end
    end

    private

    def model!(params)
      User.where(
        provider: params[:provider],
        uid:      params[:uid]
      ).first || User.new
    end

    def params!(params)
      {
        provider: params.provider,
        uid:      params.uid,
        email:    params.info.email,
        password: Devise.friendly_token[0, 20]
      }
    end

  end
end
