require "test_helper"

class TracksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @track = tracks(:enter_sandman)
    sign_in_admin
  end

  test "redirects to login when not signed in" do
    delete destroy_user_session_path
    get tracks_url
    assert_redirected_to new_user_session_path
  end

  # --- Authorization ---
  test "regular user can view index" do
    sign_in_regular_user
    get tracks_url
    assert_response :success
  end

  test "regular user can view show" do
    sign_in_regular_user
    get track_url(@track)
    assert_response :success
  end

  test "regular user cannot access new" do
    sign_in_regular_user
    get new_track_url
    assert_redirected_to root_path
  end

  test "regular user cannot create track" do
    sign_in_regular_user
    assert_no_difference("Track.count") do
      post tracks_url, params: { track: { name: "Hack" } }
    end
    assert_redirected_to root_path
  end

  test "regular user cannot edit track" do
    sign_in_regular_user
    get edit_track_url(@track)
    assert_redirected_to root_path
  end

  test "regular user cannot update track" do
    sign_in_regular_user
    patch track_url(@track), params: { track: { name: "Hacked" } }
    assert_redirected_to root_path
    assert_not_equal "Hacked", @track.reload.name
  end

  test "regular user cannot destroy track" do
    sign_in_regular_user
    assert_no_difference("Track.count") do
      delete track_url(@track)
    end
    assert_redirected_to root_path
  end

  # --- CRUD (admin) ---
  test "GET index returns success" do
    get tracks_url
    assert_response :success
  end

  test "GET index with sort by invoice_lines_count" do
    get tracks_url, params: { sort: "invoice_lines_count", direction: "desc" }
    assert_response :success
  end

  test "GET show returns success" do
    get track_url(@track)
    assert_response :success
  end

  test "GET new returns success" do
    get new_track_url
    assert_response :success
  end

  test "POST create with valid params" do
    assert_difference("Track.count") do
      post tracks_url, params: { track: {
        name: "New Track",
        album_id: albums(:black_album).id,
        media_type_id: media_types(:mpeg).id,
        genre_id: genres(:metal).id,
        composer: "Test Composer",
        milliseconds: 200000,
        bytes: 5000000,
        unit_price: 0.99
      }}
    end
    assert_redirected_to track_url(Track.last)
  end

  test "POST create with invalid params renders new" do
    assert_no_difference("Track.count") do
      post tracks_url, params: { track: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "PATCH update with valid params" do
    patch track_url(@track), params: { track: { name: "Updated Track" } }
    assert_redirected_to track_url(@track)
    assert_equal "Updated Track", @track.reload.name
  end

  test "DELETE destroy removes track" do
    track = Track.create!(
      name: "To Delete", album: albums(:back_in_black),
      media_type: media_types(:mpeg), genre: genres(:rock),
      composer: "Test", milliseconds: 100000, bytes: 1000000, unit_price: 0.99
    )
    assert_difference("Track.count", -1) do
      delete track_url(track)
    end
    assert_redirected_to tracks_url
  end
end
