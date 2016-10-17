class UsersController < ApplicationController

  def me
    unless current_user
      return redirect_to new_user_session_path
    end

    @user = current_user
  end

end
