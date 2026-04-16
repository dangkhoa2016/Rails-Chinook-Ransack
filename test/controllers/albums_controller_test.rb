require "test_helper"

class AlbumsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @album = albums(:black_album)
    sign_in_admin
  end

  # --- Authentication ---
  test "redirects to login when not signed in" do
    delete destroy_user_session_path
    get albums_url
    assert_redirected_to new_user_session_path
  end

  # --- Index ---
  test "GET index returns success" do
    get albums_url
    assert_response :success
  end

  test "GET index with sort param uses allowed column" do
    get albums_url, params: { sort: "title", direction: "asc" }
    assert_response :success
  end

  test "GET index with malicious sort param falls back safely" do
    get albums_url, params: { sort: "id); DROP TABLE albums; --" }
    assert_response :success
    assert Album.count > 0, "Albums table should still exist"
  end

  test "GET index with invalid per_page falls back to default" do
    get albums_url, params: { per_page: "99999" }
    assert_response :success
  end

  test "GET index with page overflow redirects to last page" do
    get albums_url, params: { page: "99999" }
    assert_response :redirect
  end

  # --- Show ---
  test "GET show returns success" do
    get album_url(@album)
    assert_response :success
  end

  test "GET show with invalid id redirects with alert" do
    get album_url(id: 0)
    assert_redirected_to root_path
  end

  # --- New / Create ---
  test "GET new returns success" do
    get new_album_url
    assert_response :success
  end

  test "POST create with valid params creates album" do
    assert_difference("Album.count") do
      post albums_url, params: { album: { title: "New Album", artist_id: artists(:metallica).id } }
    end
    assert_redirected_to album_url(Album.last)
  end

  test "POST create with invalid params renders new" do
    assert_no_difference("Album.count") do
      post albums_url, params: { album: { title: "", artist_id: artists(:metallica).id } }
    end
    assert_response :unprocessable_entity
  end

  # --- Edit / Update ---
  test "GET edit returns success" do
    get edit_album_url(@album)
    assert_response :success
  end

  test "PATCH update with valid params updates album" do
    patch album_url(@album), params: { album: { title: "Updated Title" } }
    assert_redirected_to album_url(@album)
    assert_equal "Updated Title", @album.reload.title
  end

  test "PATCH update with invalid params renders edit" do
    patch album_url(@album), params: { album: { title: "" } }
    assert_response :unprocessable_entity
  end

  # --- Destroy ---
  test "DELETE destroy removes album" do
    album = Album.create!(title: "To Delete", artist: artists(:no_albums_artist))
    assert_difference("Album.count", -1) do
      delete album_url(album)
    end
    assert_redirected_to albums_url
  end

  # --- JSON select ---
  test "GET json_list_for_select_element returns json" do
    get json_list_for_select_element_albums_url, params: { keyword: "Black" }
    assert_response :success
    json = JSON.parse(response.body)
    assert json.is_a?(Array)
    assert json.first.key?("value")
    assert json.first.key?("label")
  end
end
