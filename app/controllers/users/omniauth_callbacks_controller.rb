class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
 def twitter
    uid = env["omniauth.auth"]["uid"]
    user = User.find_by_uid(uid) || User.create!(:uid => uid, :name => env["omniauth.auth"]["info"]["nickname"], :access_token => env["omniauth.auth"]["credentials"]["token"], :access_token_secret => env["omniauth.auth"]["credentials"]["secret"])
    sign_in_and_redirect user
  end
end
