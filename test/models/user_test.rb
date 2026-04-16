require "test_helper"

class UserTest < ActiveSupport::TestCase
  # --- Validations ---
  test "valid with all required fields" do
    user = User.new(name: "Test", email: "test@example.com", password: "password123", role: "user")
    assert user.valid?
  end

  test "invalid without name" do
    user = User.new(email: "test@example.com", password: "password123", role: "user")
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "invalid without email" do
    user = User.new(name: "Test", password: "password123", role: "user")
    assert_not user.valid?
  end

  test "invalid with duplicate email" do
    User.create!(name: "First", email: "dup@example.com", password: "password123", role: "user")
    user = User.new(name: "Second", email: "dup@example.com", password: "password123", role: "user")
    assert_not user.valid?
  end

  test "invalid with unknown role" do
    user = User.new(name: "Test", email: "test@example.com", password: "password123", role: "superuser")
    assert_not user.valid?
    assert_includes user.errors[:role], "is not included in the list"
  end

  test "invalid with short password" do
    user = User.new(name: "Test", email: "test@example.com", password: "abc", role: "user")
    assert_not user.valid?
  end

  # --- Role helpers ---
  test "admin? returns true for admin role" do
    assert users(:admin_user).admin?
  end

  test "admin? returns false for user role" do
    assert_not users(:regular_user).admin?
  end

  test "user? returns true for user role" do
    assert users(:regular_user).user?
  end

  test "user? returns false for admin role" do
    assert_not users(:admin_user).user?
  end

  # --- display_name ---
  test "display_name returns name when present" do
    assert_equal "Admin", users(:admin_user).display_name
  end

  test "display_name falls back to email when name is blank" do
    user = users(:admin_user)
    user.name = ""
    assert_equal user.email, user.display_name
  end
end
