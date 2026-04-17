require "test_helper"

class GenresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @genre = genres(:rock)
    sign_in_admin
  end

  test "redirects to login when not signed in" do
    delete destroy_user_session_path
    get genres_url
    assert_redirected_to new_user_session_path
  end

  # --- Authorization ---
  test "regular user can view index" do
    sign_in_regular_user
    get genres_url
    assert_response :success
  end

  test "regular user can view show" do
    sign_in_regular_user
    get genre_url(@genre)
    assert_response :success
  end

  test "regular user cannot create genre" do
    sign_in_regular_user
    assert_no_difference("Genre.count") do
      post genres_url, params: { genre: { name: "Hack" } }
    end
    assert_redirected_to root_path
  end

  test "regular user cannot update genre" do
    sign_in_regular_user
    patch genre_url(@genre), params: { genre: { name: "Hacked" } }
    assert_redirected_to root_path
    assert_not_equal "Hacked", @genre.reload.name
  end

  test "regular user cannot destroy genre" do
    sign_in_regular_user
    assert_no_difference("Genre.count") do
      delete genre_url(@genre)
    end
    assert_redirected_to root_path
  end

  # --- CRUD (admin) ---
  test "GET index returns success" do
    get genres_url
    assert_response :success
  end

  test "GET show returns success" do
    get genre_url(@genre)
    assert_response :success
  end

  test "POST create with valid params" do
    assert_difference("Genre.count") do
      post genres_url, params: { genre: { name: "Classical" } }
    end
    assert_redirected_to genre_url(Genre.last)
  end

  test "POST create with invalid params renders new" do
    assert_no_difference("Genre.count") do
      post genres_url, params: { genre: { name: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "PATCH update with valid params" do
    patch genre_url(@genre), params: { genre: { name: "Updated Genre" } }
    assert_redirected_to genre_url(@genre)
    assert_equal "Updated Genre", @genre.reload.name
  end

  test "DELETE destroy removes genre" do
    genre = Genre.create!(name: "To Delete")
    assert_difference("Genre.count", -1) do
      delete genre_url(genre)
    end
    assert_redirected_to genres_url
  end
end
