class Tracker < ActiveRecord::Base
  belongs_to :user
  
  
  
  require 'net/http'
  require 'uri'

  def self.tracking
    @trackers = Tracker.includes(:user).all
    if @trackers.present?
      @trackers.each do |tracker|
        request = http_request("get","http://133.242.171.135/evaluate_tweets_mongo.py",{:q=>tracker.queue, :token=>tracker.user.access_token, :secret=>tracker.user.access_token_secret})
      end
    end
    return
  end
  
  def http_request(method, uri, query_hash = {})
    uri = URI.parse(uri) if uri.is_a? String
    method = method.to_s.strip.downcase
    query_string = (query_hash||{}).map{|k,v|
      URI.encode(k.to_s) + "=" + URI.encode(v.to_s)
    }.join("&")

    if method == "post"
      args = [Net::HTTP::Post.new(uri.path), query_string]
    else
      args = [Net::HTTP::Get.new(uri.path + (query_string.empty? ? "" : "?#{query_string}"))]
    end

    Net::HTTP.start(uri.host, uri.port) do |http|
      return http.request(*args)
    end
  end


end
