class PurchaseOrdersController < ApplicationController
  before_action :set_purchase_order, only: [ :show, :edit, :update, :destroy, :receive_items ]

  # GET /purchase_orders
  def index
    @purchase_orders = policy_scope(PurchaseOrder).order(created_at: :desc)
    # Add any specific filtering or pagination here if needed
  end

  # GET /purchase_orders/1
  def show
    authorize @purchase_order
  end

  # GET /purchase_orders/new
  def new
    @purchase_order = PurchaseOrder.new
    @purchase_order.purchase_order_items.build # Build one item by default for the form
    authorize @purchase_order
  end

  # GET /purchase_orders/1/edit
  def edit
    authorize @purchase_order
  end

  # POST /purchase_orders
  def create
    @purchase_order = PurchaseOrder.new(purchase_order_params)
    @purchase_order.user = current_user # Or appropriate user assignment
    authorize @purchase_order

    if @purchase_order.save
      redirect_to @purchase_order, notice: "Purchase order was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /purchase_orders/1
  def update
    authorize @purchase_order
    if @purchase_order.update(purchase_order_params)
      redirect_to @purchase_order, notice: "Purchase order was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /purchase_orders/1
  def destroy
    authorize @purchase_order
    @purchase_order.destroy
    redirect_to purchase_orders_url, notice: "Purchase order was successfully destroyed."
  end

  # POST /purchase_orders/1/receive_items
  def receive_items
    authorize @purchase_order
    # Add logic for receiving items for the purchase order
    # This might involve updating inventory items and transaction logs
    # Example:
    # @purchase_order.receive_all_items(current_user)
    redirect_to @purchase_order, notice: "Items marked as received (implement actual logic)."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_purchase_order
      @purchase_order = PurchaseOrder.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def purchase_order_params
      params.require(:purchase_order).permit(
        :supplier_id,
        :order_date,
        :expected_delivery_date,
        :status,
        :notes,
        # Add other attributes as needed, e.g., for line items if using nested forms
        purchase_order_items_attributes: [ :id, :product_id, :quantity, :unit_price, :_destroy ]
      )
    end
end
