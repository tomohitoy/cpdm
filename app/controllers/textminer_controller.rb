class TextminerController < ApplicationController
  before_action :authenticate_user!
  def index
  end
  def mining
    RubyPython.start(:python_exe => "python2.7.5")
    cPickle = RubyPython.import("cPickle")
    sys = RubyPython.import 'sys'
    sys.path.append("#{Rails.root}/lib")
    mining = RubyPython.import('evaluate_tweets')
    @mined = mining.twitter_search('test', current_user.access_token, current_user.access_token_secret)
    RubyPython.stop
  end
  
end
