require "test_helper"

class TopicsControllerTest < ActionController::TestCase

  setup do
    @moderator = users(:moderator_1)
    @valid_user = users(:user_1)
  end

  def topic
    @topic ||= topics :one
  end

  def forum
    @forum ||= forums :one
  end

  test "should get index and redirect to forum" do
    get :index, forum_id: forum
    assert_redirected_to assigns(:forum)
  end

  test "should not get new for logged out user" do
    get :new, forum_id: forum
    assert_redirected_to new_user_session_path
  end

  test "should get new for valid user" do
    login(@valid_user)
    get :new, forum_id: forum
    assert_response :success
  end

  test "should get new for moderator" do
    login(@moderator)
    get :new, forum_id: forum
    assert_response :success
  end

  test "should not create topic for logged out user" do
    # assert_difference('Post.count', 0) do
      assert_difference('Topic.count', 0) do
        post :create, forum_id: forum, topic: { name: "New Topic Name", description: "First Post on New Topic" }
      end
    # end

    assert_redirected_to new_user_session_path
  end

  test "should create topic for valid user" do
    login(@valid_user)
    # assert_difference('Post.count') do
      assert_difference('Topic.count') do
        post :create, forum_id: forum, topic: { name: "New Topic Name", description: "First Post on New Topic", hidden: '1' }
      end
    # end

    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:topic)
    assert_equal "New Topic Name", assigns(:topic).name
    assert_equal @valid_user, assigns(:topic).user
    assert_equal false, assigns(:topic).hidden?
    # assert_equal "First Comment on New Topic", assigns(:topic).posts.first.description
    # assert_equal @valid_user, assigns(:topic).posts.first.user
    # assert_not_nil assigns(:topic).last_post_at

    # assert_equal true, assigns(:topic).subscribed?(users(:valid))

    assert_redirected_to [assigns(:forum), assigns(:topic)]
  end

  test "should show topic for logged out user" do
    get :show, forum_id: forum, id: topic
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:topic)
    assert_response :success
  end

  test "should show topic for valid user" do
    login(@valid_user)
    get :show, forum_id: forum, id: topic
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:topic)
    assert_response :success
  end

  test "should show topic for moderator" do
    login(@moderator)
    get :show, forum_id: forum, id: topic
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:topic)
    assert_response :success
  end

  test "should not get edit for logged out user" do
    get :edit, forum_id: forum, id: topics(:one)
    assert_redirected_to new_user_session_path
  end

  test "should not get edit for user who did not create topic" do
    login(users(:user_1))
    get :edit, forum_id: forum, id: topics(:one)
    assert_redirected_to [assigns(:forum), assigns(:topic)]
  end

  test "should get edit for topic creator" do
    login(users(:user_1))
    get :edit, forum_id: forum, id: topics(:two)
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:topic)
    assert_response :success
  end

  test "should get edit for forum moderator" do
    login(@moderator)
    get :edit, forum_id: forum, id: topic
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:topic)
    assert_response :success
  end

  test "should not update topic for logged out user" do
    put :update, forum_id: forum, id: topic, topic: { name: "Updated Topic Name" }
    assert_nil assigns(:forum)
    assert_nil assigns(:topic)
    assert_redirected_to new_user_session_path
  end

  test "should not update topic for user who did not create topic" do
    login(users(:user_1))
    put :update, forum_id: forum, id: topics(:one), topic: { name: "Updated Topic Name" }
    assert_not_nil assigns(:forum)
    assert_nil assigns(:topic)
    assert_redirected_to [assigns(:forum), assigns(:topic)]
  end

  test "should update topic for topic creator" do
    login(users(:user_1))
    put :update, forum_id: forum, id: topics(:two), topic: { name: "Updated Topic Name" }
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:topic)
    assert_equal 'Updated Topic Name', assigns(:topic).name
    assert_redirected_to [assigns(:forum), assigns(:topic)]
  end

  test "should update topic for forum moderator" do
    login(@moderator)
    put :update, forum_id: forum, id: topic, topic: { name: "Updated Topic Name" }
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:topic)
    assert_equal 'Updated Topic Name', assigns(:topic).name
    assert_redirected_to [assigns(:forum), assigns(:topic)]
  end

  test "should not destroy topic for logged out user" do
    assert_difference('Topic.current.count', 0) do
      delete :destroy, forum_id: forum, id: topic
    end
    assert_nil assigns(:forum)
    assert_nil assigns(:topic)
    assert_redirected_to new_user_session_path
  end

  test "should not destroy topic for user who did not create topic" do
    login(users(:user_1))
    assert_difference('Topic.current.count', 0) do
      delete :destroy, forum_id: forum, id: topics(:one)
    end
    assert_not_nil assigns(:forum)
    assert_nil assigns(:topic)
    assert_redirected_to [assigns(:forum), assigns(:topic)]
  end

  test "should destroy topic for topic creator" do
    login(users(:user_1))
    assert_difference('Topic.current.count', -1) do
      delete :destroy, forum_id: forum, id: topics(:two)
    end
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:topic)
    assert_redirected_to assigns(:forum)
  end

  test "should destroy topic for forum moderator" do
    login(@moderator)
    assert_difference('Topic.current.count', -1) do
      delete :destroy, forum_id: forum, id: topic
    end
    assert_not_nil assigns(:forum)
    assert_not_nil assigns(:topic)
    assert_redirected_to assigns(:forum)
  end

end
