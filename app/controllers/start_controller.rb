class StartController < ApplicationController
  def index
    if current_user
  	  redirect_to :user_root
  	end
  end
end
