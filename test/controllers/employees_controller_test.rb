require "test_helper"

class EmployeesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @employee = employees(:one)
  end

  test "should get index" do
    get employees_url
    assert_response :success
  end

  test "should get new" do
    get new_employee_url
    assert_response :success
  end

  test "should create employee" do
    assert_difference("Employee.count") do
      post employees_url, params: { employee: { address: @employee.address, birth_date: @employee.birth_date, city: @employee.city, country: @employee.country, email: @employee.email, fax: @employee.fax, first_name: @employee.first_name, hire_date: @employee.hire_date, last_name: @employee.last_name, phone: @employee.phone, postal_code: @employee.postal_code, reports_to: @employee.reports_to, state: @employee.state, title: @employee.title } }
    end

    assert_redirected_to employee_url(Employee.last)
  end

  test "should show employee" do
    get employee_url(@employee)
    assert_response :success
  end

  test "should get edit" do
    get edit_employee_url(@employee)
    assert_response :success
  end

  test "should update employee" do
    patch employee_url(@employee), params: { employee: { address: @employee.address, birth_date: @employee.birth_date, city: @employee.city, country: @employee.country, email: @employee.email, fax: @employee.fax, first_name: @employee.first_name, hire_date: @employee.hire_date, last_name: @employee.last_name, phone: @employee.phone, postal_code: @employee.postal_code, reports_to: @employee.reports_to, state: @employee.state, title: @employee.title } }
    assert_redirected_to employee_url(@employee)
  end

  test "should destroy employee" do
    assert_difference("Employee.count", -1) do
      delete employee_url(@employee)
    end

    assert_redirected_to employees_url
  end
end
