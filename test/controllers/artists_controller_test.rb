require "test_helper"

class ArtistsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @artist = artists(:metallica)
    sign_in_admin
  end

  test "redirects to login when not signed in" do
    delete destroy_user_session_path
    get artists_url
    assert_redirected_to new_user_session_path
  end

  # --- Authorization ---
  test "regular user can view artists" do
    sign_in_regular_user
    get artists_url
    assert_response :success
  end

  test "regular user cannot create artist" do
    sign_in_regular_user
    assert_no_difference("Artist.count") do
      post artists_url, params: { artist: { name: "Hack" } }
    end
    assert_redirected_to root_path
  end

  test "regular user cannot destroy artist" do
    sign_in_regular_user
    assert_no_difference("Artist.count") do
      delete artist_url(@artist)
    end
    assert_redirected_to root_path
  end

  test "GET index returns success" do
    get artists_url
    assert_response :success
  end

  test "GET index with sort by albums_count" do
    get artists_url, params: { sort: "albums_count", direction: "desc" }
    assert_response :success
  end

  test "GET show returns success" do
    get artist_url(@artist)
    assert_response :success
  end

  test "GET new returns success" do
    get new_artist_url
    assert_response :success
  end

  test "POST create with valid params" do
    assert_difference("Artist.count") do
      post artists_url, params: { artist: { name: "New Artist" } }
    end
    assert_redirected_to artist_url(Artist.last)
  end

  test "POST create with invalid params renders new" do
    assert_no_difference("Artist.count") do
      post artists_url, params: { artist: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "PATCH update with valid params" do
    patch artist_url(@artist), params: { artist: { name: "Updated Name" } }
    assert_redirected_to artist_url(@artist)
    assert_equal "Updated Name", @artist.reload.name
  end

  test "DELETE destroy removes artist" do
    artist = Artist.create!(name: "To Delete")
    assert_difference("Artist.count", -1) do
      delete artist_url(artist)
    end
    assert_redirected_to artists_url
  end

  test "GET json_list_for_select_element returns json" do
    get json_list_for_select_element_artists_url, params: { keyword: "Metal" }
    assert_response :success
    json = JSON.parse(response.body)
    assert json.is_a?(Array)
  end
end
