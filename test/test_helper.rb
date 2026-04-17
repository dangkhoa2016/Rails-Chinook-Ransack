ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all
  end
end

# Helper để sign in trong controller tests
module AuthHelper
  def sign_in_as(user)
    delete destroy_user_session_path  # sign out trước
    post user_session_path, params: {
      user: { email: user.email, password: 'password123' }
    }
  end

  def sign_in_admin
    sign_in_as(users(:admin_user))
  end

  def sign_in_regular_user
    sign_in_as(users(:regular_user))
  end
end

module ActionDispatch
  class IntegrationTest
    include AuthHelper
  end
end
