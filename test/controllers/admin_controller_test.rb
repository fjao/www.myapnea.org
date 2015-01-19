require 'test_helper.rb'

class AdminControllerTest < ActionController::TestCase

  test "Owners should GET survey overview" do
    login(users(:owner))

    get :surveys
    assert_response :success
  end

  test "Moderators should GET survey overview" do
    login(users(:moderator_1))

    get :surveys
    assert_response :success
  end


  test "should raise SecurityViolation for unauthorized users" do
    login(users(:user_1))

    get :surveys

    assert_authorization_exception
  end

  # test "should allow owner to add and remove user roles" do
  #   login(users(:owner))

  #   post :add_role_to_user, format: :js, user_id: users(:user_1).id, role: roles(:moderator).name
  #   assert_response :success
  #   assert users(:user_1).has_role? :moderator

  #   post :remove_role_from_user, user_id: users(:moderator_1).id, role: roles(:moderator).name, format: :js
  #   assert_response :success
  #   refute users(:moderator_1).has_role? :moderator
  # end

  # test "should not allow a non-owner to add and remove user roles" do
  #   login(users(:moderator_1))

  #   post :add_role_to_user, format: :js, user_id: users(:user_1).id, role: roles(:moderator).name
  #   assert_authorization_exception
  #   refute users(:user_1).has_role? :moderator

  #   post :remove_role_from_user, user_id: users(:moderator_1).id, role: roles(:moderator).name, format: :js
  #   assert_authorization_exception
  #   assert users(:moderator_1).has_role? :moderator

  #   login(users(:user_1))

  #   post :add_role_to_user, format: :js, user_id: users(:user_1).id, role: roles(:moderator).name
  #   assert_authorization_exception
  #   refute users(:user_1).has_role? :moderator

  #   post :remove_role_from_user, user_id: users(:moderator_1).id, role: roles(:moderator).name, format: :js
  #   assert_authorization_exception
  #   assert users(:moderator_1).has_role? :moderator


  # end

  # Notifications
  test "should show notification administration to moderator" do
    login(users(:moderator_1))

    get :notifications

    assert_response :success
    assert_equal Notification.where(post_type: "notification"), assigns(:posts)
  end

  test "should not show notification administration to normal user" do
    login(users(:user_1))

    get :notifications

    assert_authorization_exception
  end

  # Research Topics
  test "should show research topic administration to moderator" do
    login(users(:moderator_1))

    get :research_topics

    assert_response :success

  end

  test "should not show research topic administration to normal user" do
    login(users(:user_4))

    get :research_topics

    assert_authorization_exception
  end

  # Blog
  test "should get blog admin for moderator" do
    skip "Re-engineering of blog"
    login(users(:moderator_2))

    get :blog

    assert_response :success
    assert_equal Notification.where(post_type: "blog"), assigns(:posts)

  end

  test "should not get blog admin for normal user" do
    login(users(:social))

    get :blog

    assert_authorization_exception
  end

  # Helpers
end
