require "test_helper"

class MediaTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @media_type = media_types(:mpeg)
    sign_in_admin
  end

  test "redirects to login when not signed in" do
    delete destroy_user_session_path
    get media_types_url
    assert_redirected_to new_user_session_path
  end

  test "GET index returns success" do
    get media_types_url
    assert_response :success
  end

  test "GET show returns success" do
    get media_type_url(@media_type)
    assert_response :success
  end

  test "POST create with valid params" do
    assert_difference("MediaType.count") do
      post media_types_url, params: { media_type: { name: "WAV audio file" } }
    end
    assert_redirected_to media_type_url(MediaType.last)
  end

  test "PATCH update with valid params" do
    patch media_type_url(@media_type), params: { media_type: { name: "Updated Type" } }
    assert_redirected_to media_type_url(@media_type)
    assert_equal "Updated Type", @media_type.reload.name
  end

  test "DELETE destroy removes media_type" do
    mt = MediaType.create!(name: "To Delete")
    assert_difference("MediaType.count", -1) do
      delete media_type_url(mt)
    end
    assert_redirected_to media_types_url
  end
end
