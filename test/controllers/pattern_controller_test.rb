require 'test_helper'

class PatternControllerTest < ActionController::TestCase
  test "should get user_id:integer" do
    get :user_id:integer
    assert_response :success
  end

  test "should get title:string" do
    get :title:string
    assert_response :success
  end

  test "should get context:text" do
    get :context:text
    assert_response :success
  end

  test "should get problem:text" do
    get :problem:text
    assert_response :success
  end

  test "should get solution:text" do
    get :solution:text
    assert_response :success
  end

  test "should get consequence:text" do
    get :consequence:text
    assert_response :success
  end

  test "should get category:integer" do
    get :category:integer
    assert_response :success
  end

end
