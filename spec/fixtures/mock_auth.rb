class MockAuth
  attr_reader :provider, :uid, :info, :credentials

  class Info
    attr_reader :email

    def initialize(email:)
      @email = email
    end
  end

  class Credentials
    attr_reader :token

    def initialize(token:)
      @token = token
    end
  end

  def initialize(provider:, uid:, email:, token:)
    @provider     = provider
    @uid          = uid
    @info         = Info.new(email: email)
    @credentials  = Credentials.new(token: token)
  end
end
