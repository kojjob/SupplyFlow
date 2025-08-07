class SalesOrdersController < ApplicationController
  before_action :set_sales_order, only: [ :show, :edit, :update, :destroy, :ship_items ]

  # GET /sales_orders
  def index
    @sales_orders = policy_scope(SalesOrder).order(created_at: :desc)
    # Add any specific filtering or pagination here if needed
  end

  # GET /sales_orders/1
  def show
    authorize @sales_order
  end

  # GET /sales_orders/new
  def new
    @sales_order = SalesOrder.new
    authorize @sales_order
  end

  # GET /sales_orders/1/edit
  def edit
    authorize @sales_order
  end

  # POST /sales_orders
  def create
    @sales_order = SalesOrder.new(sales_order_params)
    @sales_order.user = current_user # Or appropriate user assignment
    authorize @sales_order

    if @sales_order.save
      redirect_to @sales_order, notice: "Sales order was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /sales_orders/1
  def update
    authorize @sales_order
    if @sales_order.update(sales_order_params)
      redirect_to @sales_order, notice: "Sales order was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /sales_orders/1
  def destroy
    authorize @sales_order
    @sales_order.destroy
    redirect_to sales_orders_url, notice: "Sales order was successfully destroyed."
  end

  # POST /sales_orders/1/ship_items
  def ship_items
    authorize @sales_order
    # Add logic for shipping items for the sales order
    # This might involve updating inventory items and transaction logs
    # Example:
    # @sales_order.ship_all_items(current_user)
    redirect_to @sales_order, notice: "Items marked as shipped (implement actual logic)."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sales_order
      @sales_order = SalesOrder.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def sales_order_params
      params.require(:sales_order).permit(
        :customer_id,
        :order_date,
        :shipping_date,
        :delivery_date,
        :status,
        :notes,
        :shipping_address,
        :billing_address,
        # Add other attributes as needed, e.g., for line items if using nested forms
        sales_order_items_attributes: [ :id, :product_id, :quantity, :unit_price, :_destroy ]
      )
    end
end
