class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :confirmable,
    :omniauthable, :omniauth_providers => [:facebook, :twitter] # ココ追加

  # 連携済みかどうか
  def connected?(provider)
    return eval("self.#{provider}_id.nil?")
  end

  # 以下、コールバックで呼ばれるメソッド追加
  def self.find_for_facebook_oauth(access_token, signed_in_resource = nil)
    data = access_token.extra.raw_info
    User.where(:facebook_id => data.id).first
  end

  def self.find_for_twitter_oauth(access_token, signed_in_resource = nil)
    data = access_token
    User.where(:twitter_id => data.uid).first
  end

  def connect_with provider, authdata
    logger.info("AUTH: #{authdata.inspect}")

    case provider
    when :twitter
      self.twitter_id = authdata['uid']
      self.twitter_token = authdata['credentials']['token']
      self.twitter_secret = authdata['credentials']['secret']
    when :facebook
      self.facebook_id = authdata['uid']
      self.facebook_token = authdata['credentials']['token']
    end
    save
  end
end	