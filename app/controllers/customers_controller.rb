class CustomersController < ApplicationController
  before_action :set_customer, only: [ :show, :edit, :update, :destroy ]

  # GET /customers
  def index
    authorize Customer
    @customers = policy_scope(Customer).order(name: :asc)

    if params[:query].present?
      query = "%#{params[:query]}%"
      @customers = @customers.where("name ILIKE ? OR email ILIKE ? OR phone ILIKE ?", query, query, query)
    end

    if params[:active].present?
      @customers = @customers.where(active: params[:active] == "true")
    end

    # For pagination without using Kaminari
    @total_count = @customers.count
    @customers = @customers.limit(25).offset((params[:page].to_i || 0) * 25)

    respond_to do |format|
      format.html
      format.json { render json: @customers }
    end
  end

  # GET /customers/1
  def show
    authorize @customer

    @sales_orders = @customer.sales_orders.order(order_date: :desc).limit(10)
    @payments = @customer.payments.order(payment_date: :desc).limit(10)

    respond_to do |format|
      format.html
      format.json { render json: @customer }
    end
  end

  # GET /customers/new
  def new
    authorize Customer
    @customer = Customer.new
  end

  # GET /customers/1/edit
  def edit
    authorize @customer
  end

  # POST /customers
  def create
    @customer = Customer.new(customer_params)
    @customer.organization = current_organization

    authorize @customer

    respond_to do |format|
      if @customer.save
        # Record the user activity
        current_user.record_activity("created_customer", { customer_id: @customer.id, customer_name: @customer.name })

        format.html { redirect_to customer_path(@customer), notice: "Customer was successfully created." }
        format.json { render json: @customer, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customers/1
  def update
    authorize @customer

    respond_to do |format|
      if @customer.update(customer_params)
        # Record the user activity
        current_user.record_activity("updated_customer", { customer_id: @customer.id, customer_name: @customer.name })

        format.html { redirect_to customer_path(@customer), notice: "Customer was successfully updated." }
        format.json { render json: @customer }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1
  def destroy
    authorize @customer

    customer_name = @customer.name
    customer_id = @customer.id

    # Check if customer can be safely deleted
    if @customer.sales_orders.exists?
      respond_to do |format|
        format.html { redirect_to customers_path, alert: "Cannot delete customer with associated sales orders." }
        format.json { render json: { error: "Cannot delete customer with associated sales orders." }, status: :unprocessable_entity }
      end
      return
    end

    if @customer.destroy
      # Record the user activity
      current_user.record_activity("deleted_customer", { customer_id: customer_id, customer_name: customer_name })

      respond_to do |format|
        format.html { redirect_to customers_path, notice: "Customer was successfully deleted." }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to customers_path, alert: "Failed to delete customer." }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions
  def set_customer
    @customer = Customer.find(params[:id])
  end

  # Only allow a list of trusted parameters through
  def customer_params
    params.require(:customer).permit(
      :name,
      :contact_person,
      :email,
      :phone,
      :address,
      :city,
      :state,
      :postal_code,
      :country,
      :tax_id,
      :credit_limit,
      :active,
      :notes
    )
  end
end
