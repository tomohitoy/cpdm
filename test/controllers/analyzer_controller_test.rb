require 'test_helper'

class AnalyzerControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
