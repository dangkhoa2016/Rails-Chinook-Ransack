require "test_helper"

class EmployeesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @employee = employees(:sales_agent)
    sign_in_admin
  end

  test "redirects to login when not signed in" do
    delete destroy_user_session_path
    get employees_url
    assert_redirected_to new_user_session_path
  end

  # --- Authorization ---
  test "regular user can view index" do
    sign_in_regular_user
    get employees_url
    assert_response :success
  end

  test "regular user can view show" do
    sign_in_regular_user
    get employee_url(@employee)
    assert_response :success
  end

  test "regular user cannot access new" do
    sign_in_regular_user
    get new_employee_url
    assert_redirected_to root_path
  end

  test "regular user cannot create employee" do
    sign_in_regular_user
    assert_no_difference("Employee.count") do
      post employees_url, params: { employee: { first_name: "Hack" } }
    end
    assert_redirected_to root_path
  end

  test "regular user cannot update employee" do
    sign_in_regular_user
    patch employee_url(@employee), params: { employee: { title: "Hacked" } }
    assert_redirected_to root_path
    assert_not_equal "Hacked", @employee.reload.title
  end

  test "regular user cannot destroy employee" do
    sign_in_regular_user
    assert_no_difference("Employee.count") do
      delete employee_url(@employee)
    end
    assert_redirected_to root_path
  end

  # --- CRUD (admin) ---
  test "GET index returns success" do
    get employees_url
    assert_response :success
  end

  test "GET show returns success" do
    get employee_url(@employee)
    assert_response :success
  end

  test "POST create with valid params" do
    assert_difference("Employee.count") do
      post employees_url, params: { employee: {
        first_name: "New", last_name: "Employee",
        email: "new.emp@example.com", title: "Agent",
        address: "1 St", city: "NYC", state: "NY",
        country: "USA", postal_code: "10001",
        birth_date: "1990-01-01", hire_date: "2020-01-01"
      }}
    end
    assert_redirected_to employee_url(Employee.last)
  end

  test "PATCH update with valid params" do
    patch employee_url(@employee), params: { employee: { title: "Senior Agent" } }
    assert_redirected_to employee_url(@employee)
    assert_equal "Senior Agent", @employee.reload.title
  end

  test "DELETE destroy removes employee" do
    emp = Employee.create!(
      first_name: "Del", last_name: "Me", email: "del.emp@example.com",
      title: "Agent", address: "1 St", city: "NYC", state: "NY",
      country: "USA", postal_code: "10001",
      birth_date: "1990-01-01", hire_date: "2020-01-01"
    )
    assert_difference("Employee.count", -1) do
      delete employee_url(emp)
    end
    assert_redirected_to employees_url
  end
end
