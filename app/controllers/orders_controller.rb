class OrdersController < ApplicationController
  before_action :set_order, only: [ :show, :edit, :update, :destroy, :cancel, :ship, :deliver, :return, :invoice ]

  # GET /orders
  def index
    authorize Order
    @orders = policy_scope(Order).includes(:customer, :user)

    # Apply filters if present
    if params[:status].present?
      @orders = @orders.by_status(params[:status])
    end

    if params[:payment_status].present?
      @orders = @orders.by_payment_status(params[:payment_status])
    end

    if params[:customer_id].present?
      @orders = @orders.by_customer(params[:customer_id])
      @customer = Customer.find_by(id: params[:customer_id])
    end

    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date]) rescue nil
      end_date = Date.parse(params[:end_date]) rescue nil

      if start_date && end_date
        @orders = @orders.by_date_range(start_date, end_date)
      end
    end

    if params[:query].present?
      query = "%#{params[:query]}%"
      @orders = @orders.joins(:customer)
                      .where("orders.order_number ILIKE ? OR customers.name ILIKE ?",
                             query, query)
    end

    # Sort orders
    case params[:sort]
    when "date_asc"
      @orders = @orders.order(order_date: :asc)
    when "date_desc"
      @orders = @orders.order(order_date: :desc)
    when "total_asc"
      @orders = @orders.order(total_amount: :asc)
    when "total_desc"
      @orders = @orders.order(total_amount: :desc)
    else
      # Default sort is by creation date, newest first
      @orders = @orders.order(created_at: :desc)
    end

    # For pagination - limit to 25 records
    @total_count = @orders.count
    @orders = @orders.limit(25).offset((params[:page].to_i || 0) * 25)

    respond_to do |format|
      format.html
      format.json { render json: @orders }
    end
  end

  # GET /orders/1
  def show
    authorize @order

    @order_items = @order.order_items.includes(:product)
    @payments = @order.payments.order(payment_date: :desc)

    respond_to do |format|
      format.html
      format.json { render json: @order }
      format.pdf {
        pdf = @order.to_pdf
        send_data pdf, filename: "order-#{@order.order_number}.pdf", type: "application/pdf", disposition: "inline"
      }
    end
  end

  # GET /orders/new
  def new
    authorize Order
    @order = Order.new
    @order.order_date = Date.today

    # Pre-fill customer if provided
    if params[:customer_id].present?
      @customer = Customer.find_by(id: params[:customer_id])
      @order.customer = @customer if @customer
    end

    # Add a blank order item for the form
    @order.order_items.build

    # Get available products for selection
    @products = policy_scope(Product).active.order(name: :asc)
    @customers = policy_scope(Customer).active.order(name: :asc)
  end

  # GET /orders/1/edit
  def edit
    authorize @order

    # Don't allow editing of completed orders
    if %w[delivered canceled returned].include?(@order.status)
      redirect_to @order, alert: "Completed orders cannot be edited."
      return
    end

    @products = policy_scope(Product).active.order(name: :asc)
    @customers = policy_scope(Customer).active.order(name: :asc)
  end

  # POST /orders
  def create
    @order = Order.new(order_params)
    @order.organization = current_organization
    @order.user = current_user

    authorize @order

    respond_to do |format|
      if @order.save
        # Record the user activity
        current_user.record_activity("created_order", {
          order_id: @order.id,
          order_number: @order.order_number,
          customer_id: @order.customer_id,
          total_amount: @order.total_amount
        })

        format.html { redirect_to order_path(@order), notice: "Order was successfully created." }
        format.json { render json: @order, status: :created }
      else
        @products = policy_scope(Product).active.order(name: :asc)
        @customers = policy_scope(Customer).active.order(name: :asc)

        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  def update
    authorize @order

    # Don't allow updating of completed orders
    if %w[delivered canceled returned].include?(@order.status)
      respond_to do |format|
        format.html { redirect_to @order, alert: "Completed orders cannot be updated." }
        format.json { render json: { error: "Completed orders cannot be updated." }, status: :unprocessable_entity }
      end
      return
    end

    respond_to do |format|
      if @order.update(order_params)
        # Record the user activity
        current_user.record_activity("updated_order", {
          order_id: @order.id,
          order_number: @order.order_number,
          status: @order.status
        })

        format.html { redirect_to order_path(@order), notice: "Order was successfully updated." }
        format.json { render json: @order }
      else
        @products = policy_scope(Product).active.order(name: :asc)
        @customers = policy_scope(Customer).active.order(name: :asc)

        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  def destroy
    authorize @order

    # Only allow deletion of draft orders
    unless @order.status == "draft"
      respond_to do |format|
        format.html { redirect_to orders_path, alert: "Only draft orders can be deleted." }
        format.json { render json: { error: "Only draft orders can be deleted." }, status: :unprocessable_entity }
      end
      return
    end

    order_number = @order.order_number
    order_id = @order.id

    if @order.destroy
      # Record the user activity
      current_user.record_activity("deleted_order", {
        order_id: order_id,
        order_number: order_number
      })

      respond_to do |format|
        format.html { redirect_to orders_path, notice: "Order was successfully deleted." }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to orders_path, alert: "Failed to delete order." }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /orders/1/cancel
  def cancel
    authorize @order

    unless @order.can_be_canceled?
      respond_to do |format|
        format.html { redirect_to @order, alert: "This order cannot be canceled." }
        format.json { render json: { error: "This order cannot be canceled." }, status: :unprocessable_entity }
      end
      return
    end

    if @order.cancel
      # Record the user activity
      current_user.record_activity("canceled_order", {
        order_id: @order.id,
        order_number: @order.order_number
      })

      respond_to do |format|
        format.html { redirect_to @order, notice: "Order was successfully canceled." }
        format.json { render json: @order }
      end
    else
      respond_to do |format|
        format.html { redirect_to @order, alert: "Failed to cancel order." }
        format.json { render json: { error: "Failed to cancel order." }, status: :unprocessable_entity }
      end
    end
  end

  # POST /orders/1/ship
  def ship
    authorize @order

    # Only pending or processing orders can be shipped
    unless %w[pending processing].include?(@order.status)
      respond_to do |format|
        format.html { redirect_to @order, alert: "This order cannot be shipped." }
        format.json { render json: { error: "This order cannot be shipped." }, status: :unprocessable_entity }
      end
      return
    end

    @order.shipping_date = Date.today

    if @order.update(status: "shipped")
      # Record the user activity
      current_user.record_activity("shipped_order", {
        order_id: @order.id,
        order_number: @order.order_number
      })

      respond_to do |format|
        format.html { redirect_to @order, notice: "Order was successfully marked as shipped." }
        format.json { render json: @order }
      end
    else
      respond_to do |format|
        format.html { redirect_to @order, alert: "Failed to mark order as shipped." }
        format.json { render json: { error: "Failed to mark order as shipped." }, status: :unprocessable_entity }
      end
    end
  end

  # POST /orders/1/deliver
  def deliver
    authorize @order

    # Only shipped orders can be delivered
    unless @order.status == "shipped"
      respond_to do |format|
        format.html { redirect_to @order, alert: "This order cannot be marked as delivered." }
        format.json { render json: { error: "This order cannot be marked as delivered." }, status: :unprocessable_entity }
      end
      return
    end

    @order.delivery_date = Date.today

    if @order.update(status: "delivered")
      # Record the user activity
      current_user.record_activity("delivered_order", {
        order_id: @order.id,
        order_number: @order.order_number
      })

      respond_to do |format|
        format.html { redirect_to @order, notice: "Order was successfully marked as delivered." }
        format.json { render json: @order }
      end
    else
      respond_to do |format|
        format.html { redirect_to @order, alert: "Failed to mark order as delivered." }
        format.json { render json: { error: "Failed to mark order as delivered." }, status: :unprocessable_entity }
      end
    end
  end

  # POST /orders/1/return
  def return
    authorize @order

    unless @order.can_be_returned?
      respond_to do |format|
        format.html { redirect_to @order, alert: "This order cannot be returned." }
        format.json { render json: { error: "This order cannot be returned." }, status: :unprocessable_entity }
      end
      return
    end

    if @order.return_order
      # Record the user activity
      current_user.record_activity("returned_order", {
        order_id: @order.id,
        order_number: @order.order_number
      })

      respond_to do |format|
        format.html { redirect_to @order, notice: "Order was successfully marked as returned." }
        format.json { render json: @order }
      end
    else
      respond_to do |format|
        format.html { redirect_to @order, alert: "Failed to mark order as returned." }
        format.json { render json: { error: "Failed to mark order as returned." }, status: :unprocessable_entity }
      end
    end
  end

  # GET /orders/1/invoice
  def invoice
    authorize @order

    respond_to do |format|
      format.html
      format.pdf {
        pdf = @order.to_pdf
        send_data pdf, filename: "invoice-#{@order.order_number}.pdf", type: "application/pdf", disposition: "inline"
      }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions
  def set_order
    @order = Order.find(params[:id])
  end

  # Only allow a list of trusted parameters through
  def order_params
    params.require(:order).permit(
      :customer_id,
      :order_date,
      :shipping_date,
      :delivery_date,
      :status,
      :payment_status,
      :shipping_method,
      :tracking_number,
      :shipping_address,
      :billing_address,
      :shipping_amount,
      :tax_amount,
      :discount_amount,
      :notes,
      order_items_attributes: [
        :id,
        :product_id,
        :quantity,
        :unit_price,
        :tax_rate,
        :tax_amount,
        :discount_amount,
        :shipped_quantity,
        :notes,
        :_destroy
      ]
    )
  end
end
