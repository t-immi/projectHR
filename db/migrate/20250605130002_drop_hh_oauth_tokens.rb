class DropHhOauthTokens < ActiveRecord::Migration[8.1]
  def change
    drop_table :hh_oauth_tokens, if_exists: true
  end
end
