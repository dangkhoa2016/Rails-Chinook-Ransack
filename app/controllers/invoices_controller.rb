class InvoicesController < ApplicationController
  include Filterable
  include Sortable
  before_action :set_invoice, only: %i[ show edit update destroy ]

  # GET /invoices or /invoices.json
  def index
    begin
      @pagy, @invoices = process_filters(model_query)
    rescue => e
      if e.is_a?(Pagy::OverflowError)
        @pagy = Pagy.new(count: 0)
        @invoices = Invoice.none
      else
        raise e
      end
    end

    if @invoices.present?
      invoice_lines_count = InvoiceLine.count_by_model_ids(:invoice, @invoices.pluck(:id))
      @invoices.each do |invoice|
        invoice.invoice_lines_count = invoice_lines_count[invoice.id] || 0
      end
    end

    render_index('table')
  end

  def json_list_for_select_element
    query = params[:keyword].to_s.strip
    if query.match?(/^\d+$/) # search by id
      result = Invoice.includes(:customer).where('CAST(id AS TEXT) LIKE ?', "%#{query}%")
    else
      result = Invoice.includes(:customer).ransack(customer_first_name_or_customer_last_name_cont: query).result
    end

    _, invoices = pagy(result)
    invoices = invoices.map do |invoice|
      { value: invoice.id, label: "ID: #{invoice.id} - By: #{invoice.customer&.full_name}" }
    end
    render json: invoices
  end

  # GET /invoices/1 or /invoices/1.json
  def show
  end

  # GET /invoices/new
  def new
    @invoice = Invoice.new
  end

  # GET /invoices/1/edit
  def edit
  end

  # POST /invoices or /invoices.json
  def create
    @invoice = Invoice.new(invoice_params)

    respond_to do |format|
      if @invoice.save
        format.html { redirect_to @invoice, notice: "Invoice was successfully created." }
        format.json { render :show, status: :created, location: @invoice }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invoices/1 or /invoices/1.json
  def update
    respond_to do |format|
      if @invoice.update(invoice_params)
        format.html { redirect_to @invoice, notice: "Invoice was successfully updated." }
        format.json { render :show, status: :ok, location: @invoice }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invoices/1 or /invoices/1.json
  def destroy
    @invoice.destroy!

    respond_to do |format|
      format.html { redirect_to invoices_path, status: :see_other, notice: "Invoice was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      @invoice = Invoice.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def invoice_params
      params.require(:invoice).permit(:customer_id, :invoice_date, :billing_address, :billing_city, :billing_state, :billing_country, :billing_postal_code, :total)
    end


    def default_ransack_params
      :billing_address_or_billing_postal_code_or_customer_first_name_or_customer_last_name_cont
    end

    def model_query
      if is_sort_by_customer?
        Invoice.left_joins(:customer).preload(:customer)
      elsif is_sort_by_invoice_lines_count?
        Invoice.includes(:customer).left_joins(:invoice_lines).group('invoices.id')
      else
        Invoice.includes(:customer)
      end
    end

    def is_sort_by_customer?
      @is_sort_by_customer ||= (sort_column == 'customer')
    end

    def is_sort_by_invoice_lines_count?
      @is_sort_by_invoice_lines_count ||= (sort_column == 'invoice_lines_count')
    end

    def sorting_params
      if is_sort_by_customer?
        {
          'customers.first_name' => sort_direction,
          'customers.last_name' => sort_direction
        }
      elsif is_sort_by_invoice_lines_count?
        "COUNT(invoice_lines.id) #{sort_direction}"
      else
        super
      end
    end
end
