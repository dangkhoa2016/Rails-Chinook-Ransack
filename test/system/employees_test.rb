require "application_system_test_case"

class EmployeesTest < ApplicationSystemTestCase
  setup do
    @employee = employees(:one)
  end

  test "visiting the index" do
    visit employees_url
    assert_selector "h1", text: "Employees"
  end

  test "should create employee" do
    visit employees_url
    click_on "New employee"

    fill_in "Address", with: @employee.address
    fill_in "Birth date", with: @employee.birth_date
    fill_in "City", with: @employee.city
    fill_in "Country", with: @employee.country
    fill_in "Email", with: @employee.email
    fill_in "Fax", with: @employee.fax
    fill_in "First name", with: @employee.first_name
    fill_in "Hire date", with: @employee.hire_date
    fill_in "Last name", with: @employee.last_name
    fill_in "Phone", with: @employee.phone
    fill_in "Postal code", with: @employee.postal_code
    fill_in "Reports to", with: @employee.reports_to
    fill_in "State", with: @employee.state
    fill_in "Title", with: @employee.title
    click_on "Create Employee"

    assert_text "Employee was successfully created"
    click_on "Back"
  end

  test "should update Employee" do
    visit employee_url(@employee)
    click_on "Edit this employee", match: :first

    fill_in "Address", with: @employee.address
    fill_in "Birth date", with: @employee.birth_date
    fill_in "City", with: @employee.city
    fill_in "Country", with: @employee.country
    fill_in "Email", with: @employee.email
    fill_in "Fax", with: @employee.fax
    fill_in "First name", with: @employee.first_name
    fill_in "Hire date", with: @employee.hire_date
    fill_in "Last name", with: @employee.last_name
    fill_in "Phone", with: @employee.phone
    fill_in "Postal code", with: @employee.postal_code
    fill_in "Reports to", with: @employee.reports_to
    fill_in "State", with: @employee.state
    fill_in "Title", with: @employee.title
    click_on "Update Employee"

    assert_text "Employee was successfully updated"
    click_on "Back"
  end

  test "should destroy Employee" do
    visit employee_url(@employee)
    click_on "Destroy this employee", match: :first

    assert_text "Employee was successfully destroyed"
  end
end
