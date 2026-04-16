require "test_helper"

class PlaylistsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @playlist = playlists(:rock_classics)
    sign_in_admin
  end

  test "redirects to login when not signed in" do
    delete destroy_user_session_path
    get playlists_url
    assert_redirected_to new_user_session_path
  end

  test "GET index returns success" do
    get playlists_url
    assert_response :success
  end

  test "GET show returns success" do
    get playlist_url(@playlist)
    assert_response :success
  end

  test "POST create with valid params" do
    assert_difference("Playlist.count") do
      post playlists_url, params: { playlist: { name: "New Playlist" } }
    end
    assert_redirected_to playlist_url(Playlist.last)
  end

  test "PATCH update with valid params" do
    patch playlist_url(@playlist), params: { playlist: { name: "Updated" } }
    assert_redirected_to playlist_url(@playlist)
    assert_equal "Updated", @playlist.reload.name
  end

  test "DELETE destroy removes playlist" do
    playlist = Playlist.create!(name: "To Delete")
    assert_difference("Playlist.count", -1) do
      delete playlist_url(playlist)
    end
    assert_redirected_to playlists_url
  end
end
