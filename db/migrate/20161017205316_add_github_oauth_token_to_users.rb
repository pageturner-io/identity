class AddGithubOauthTokenToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :github_oauth_token, :string
  end
end
