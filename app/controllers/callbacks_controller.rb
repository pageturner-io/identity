class CallbacksController < Devise::OmniauthCallbacksController
  def github
    Github::Authenticate.run(request.env["omniauth.auth"]) do |op|
      sign_in_and_redirect op.model
    end
  end
end
