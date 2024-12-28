class EmployeesController < ApplicationController
  include Filterable
  before_action :set_employee, only: %i[ show edit update destroy ]

  # GET /employees or /employees.json
  def index
    begin
      @pagy, @employees = process_filters(model_query)
    rescue => e
      if e.is_a?(Pagy::OverflowError)
        @pagy = Pagy.new(count: 0)
        @employees = Employee.none
      else
        raise e
      end
    end

    if @employees.present?
      customers_count = Customer.count_by_employee_ids(@employees.pluck(:id))
      subordinates_count = Employee.count_by_manager_ids(@employees.pluck(:id))
      @employees.each do |employee|
        employee.customers_count = customers_count[employee.id] || 0
        employee.subordinates_count = subordinates_count[employee.id] || 0
      end
    end
  end

  def json_list_for_select_element
    _, employees = pagy(Employee.ransack(first_name_or_last_name_cont: params[:keyword]).result)
    employees = employees.map do |employee|
      { value: employee.id, label: employee.full_name }
    end
    render json: employees
  end

  # GET /employees/1 or /employees/1.json
  def show
  end

  # GET /employees/new
  def new
    @employee = Employee.new
  end

  # GET /employees/1/edit
  def edit
  end

  # POST /employees or /employees.json
  def create
    @employee = Employee.new(employee_params)

    respond_to do |format|
      if @employee.save
        format.html { redirect_to @employee, notice: "Employee was successfully created." }
        format.json { render :show, status: :created, location: @employee }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /employees/1 or /employees/1.json
  def update
    respond_to do |format|
      if @employee.update(employee_params)
        format.html { redirect_to @employee, notice: "Employee was successfully updated." }
        format.json { render :show, status: :ok, location: @employee }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employees/1 or /employees/1.json
  def destroy
    @employee.destroy!

    respond_to do |format|
      format.html { redirect_to employees_path, status: :see_other, notice: "Employee was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_employee
      @employee = Employee.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def employee_params
      params.require(:employee).permit(:last_name, :first_name, :email, :title, :reports_to, :birth_date, :hire_date, :address, :city, :state, :country, :postal_code, :phone, :fax)
    end
    
    def default_ransack_params
      :first_name_or_last_name_or_address_or_phone_or_email_cont
    end

    def model_query
      if is_sort_by_reporting_to?
        Employee.left_joins(:reporting_to).preload(:reporting_to)
      else
        Employee.includes(:reporting_to)
      end
    end

    def is_sort_by_reporting_to?
      @is_sort_by_reporting_to ||= (params[:sort]&.downcase == 'reporting_to')
    end

    def sorting_params
      if is_sort_by_reporting_to?
        sort_direction = params[:direction] || 'desc'

        {
          'reporting_tos_employees.first_name' => sort_direction,
          'reporting_tos_employees.last_name' => sort_direction
        }
      else
        super
      end
    end
end
