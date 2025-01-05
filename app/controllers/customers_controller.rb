class CustomersController < ApplicationController
  include Filterable
  include Sortable
  before_action :set_customer, only: %i[ show edit update destroy ]

  # GET /customers or /customers.json
  def index
    begin
      @pagy, @customers = process_filters(model_query)
    rescue => e
      if e.is_a?(Pagy::OverflowError)
        @pagy = Pagy.new(count: 0)
        @customers = Customer.none
      else
        raise e
      end
    end

    if @customers.present?
      invoices_count = Invoice.count_by_model_ids(:customer, @customers.pluck(:id))
      @customers.each do |customer|
        customer.invoices_count = invoices_count[customer.id] || 0
      end
    end

    render_index('table')
  end

  def json_list_for_select_element
    _, customers = pagy(Customer.ransack(first_name_or_last_name_cont_cont: params[:keyword]).result)
    customers = customers.map do |customer|
      { value: customer.id, label: customer.full_name }
    end
    render json: customers
  end

  # GET /customers/1 or /customers/1.json
  def show
  end

  # GET /customers/new
  def new
    @customer = Customer.new
  end

  # GET /customers/1/edit
  def edit
  end

  # POST /customers or /customers.json
  def create
    @customer = Customer.new(customer_params)

    respond_to do |format|
      if @customer.save
        format.html { redirect_to @customer, notice: "Customer was successfully created." }
        format.json { render :show, status: :created, location: @customer }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customers/1 or /customers/1.json
  def update
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to @customer, notice: "Customer was successfully updated." }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1 or /customers/1.json
  def destroy
    @customer.destroy!

    respond_to do |format|
      format.html { redirect_to customers_path, status: :see_other, notice: "Customer was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def customer_params
      params.require(:customer).permit(:first_name, :last_name, :company, :address, :city, :state, :country, :postal_code, :phone, :fax, :email, :support_rep_id)
    end

    def default_ransack_params
      :first_name_or_last_name_or_address_or_phone_or_email_cont
    end

    def model_query
      if is_sort_by_support_rep?
        Customer.left_joins(:support_rep).preload(:support_rep)
      elsif is_sort_by_invoices_count?
        Customer.includes(:support_rep).left_joins(:invoices).group('customers.id')
      else
        Customer.includes(:support_rep)
      end
    end

    def is_sort_by_support_rep?
      @is_sort_by_support_rep ||= (sort_column == 'support_rep')
    end

    def is_sort_by_invoices_count?
      @is_sort_by_invoices_count ||= (sort_column == 'invoices_count')
    end

    def sorting_params
      if is_sort_by_support_rep?
        {
          'employees.first_name' => sort_direction,
          'employees.last_name' => sort_direction
        }
      elsif is_sort_by_invoices_count?
        "COUNT(invoices.id) #{sort_direction}"
      else
        super
      end
    end
end
