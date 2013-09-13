class UsersController < ApplicationController

 # 連携を解除するメソッド
 def disconnect_omniauth_provider
    provider = params[:provider]
    if Devise.omniauth_providers.include? provider.to_sym
      current_user.update_attributes(
        {
          "#{provider}_id" =>  nil,
          "#{provider}_token" =>  nil,
          "#{provider}_secret" =>  nil,          
        }
      )
      current_user.save

      flash[:success] = "Your account has been disconnected from #{provider.titleize}."
    end
    redirect_to edit_user_registration_path
  end
  
  ・・・
end
