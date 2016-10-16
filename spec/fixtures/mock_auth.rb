class MockAuth
  attr_reader :provider, :uid, :info

  class Info
    attr_reader :email

    def initialize(email:)
      @email = email
    end
  end

  def initialize(provider:, uid:, email:)
    @provider = provider
    @uid      = uid
    @info     = Info.new(email: email)
  end
end
