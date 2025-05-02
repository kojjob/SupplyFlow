class InventoryController < ApplicationController
  before_action :set_inventory_item, only: [:adjust, :transfer]
  
  def index
    authorize :inventory, :index?
    
    @inventory_items = policy_scope(InventoryItem)
                       .includes(:product, :location)
                       .order('locations.name ASC, products.name ASC')
                       .page(params[:page])
                       .per(50)
    
    if params[:location_id].present?
      @inventory_items = @inventory_items.where(location_id: params[:location_id])
      @location = Location.find_by(id: params[:location_id])
    end
    
    if params[:product_id].present?
      @inventory_items = @inventory_items.where(product_id: params[:product_id])
      @product = Product.find_by(id: params[:product_id])
    end
    
    if params[:status].present?
      @inventory_items = @inventory_items.where(status: params[:status])
    end
    
    if params[:query].present?
      @inventory_items = @inventory_items.joins(:product)
                         .where('products.name ILIKE ? OR products.sku ILIKE ?', 
                               "%#{params[:query]}%", 
                               "%#{params[:query]}%")
    end
    
    respond_to do |format|
      format.html
      format.json { render json: @inventory_items }
    end
  end
  
  def transactions
    authorize :inventory, :transactions?
    
    @transactions = policy_scope(InventoryTransaction)
                    .includes(:product, :source_location, :destination_location, :user)
                    .order(created_at: :desc)
                    .page(params[:page])
                    .per(50)
    
    if params[:location_id].present?
      @transactions = @transactions.by_location(params[:location_id])
      @location = Location.find_by(id: params[:location_id])
    end
    
    if params[:product_id].present?
      @transactions = @transactions.by_product(params[:product_id])
      @product = Product.find_by(id: params[:product_id])
    end
    
    if params[:transaction_type].present?
      @transactions = @transactions.by_type(params[:transaction_type])
    end
    
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date]) rescue nil
      end_date = Date.parse(params[:end_date]) rescue nil
      
      if start_date && end_date
        @transactions = @transactions.by_date_range(start_date, end_date)
      end
    end
    
    respond_to do |format|
      format.html
      format.json { render json: @transactions }
    end
  end
  
  def adjust
    authorize @inventory_item
    
    amount = params[:amount].to_i
    transaction_type = amount.positive? ? 'stock_addition' : 'stock_removal'
    
    if amount.zero?
      respond_to do |format|
        format.html { redirect_back(fallback_location: inventory_path, alert: "Adjustment amount cannot be zero.") }
        format.json { render json: { error: "Adjustment amount cannot be zero." }, status: :unprocessable_entity }
      end
      return
    end
    
    if amount.negative? && amount.abs > @inventory_item.available_quantity
      respond_to do |format|
        format.html { redirect_back(fallback_location: inventory_path, alert: "Cannot remove more than available quantity.") }
        format.json { render json: { error: "Cannot remove more than available quantity." }, status: :unprocessable_entity }
      end
      return
    end
    
    success = if amount.positive?
                @inventory_item.add_stock(amount, transaction_type, current_user.id, params[:notes])
              else
                @inventory_item.remove_stock(amount.abs, transaction_type, current_user.id, params[:notes])
              end
    
    respond_to do |format|
      if success
        format.html { redirect_back(fallback_location: inventory_path, notice: "Inventory successfully adjusted.") }
        format.json { render json: @inventory_item }
      else
        format.html { redirect_back(fallback_location: inventory_path, alert: "Failed to adjust inventory.") }
        format.json { render json: { error: "Failed to adjust inventory." }, status: :unprocessable_entity }
      end
    end
  end
  
  def transfer
    authorize @inventory_item
    
    destination_location_id = params[:destination_location_id]
    amount = params[:amount].to_i
    
    if amount <= 0
      respond_to do |format|
        format.html { redirect_back(fallback_location: inventory_path, alert: "Transfer amount must be greater than zero.") }
        format.json { render json: { error: "Transfer amount must be greater than zero." }, status: :unprocessable_entity }
      end
      return
    end
    
    if amount > @inventory_item.available_quantity
      respond_to do |format|
        format.html { redirect_back(fallback_location: inventory_path, alert: "Cannot transfer more than available quantity.") }
        format.json { render json: { error: "Cannot transfer more than available quantity." }, status: :unprocessable_entity }
      end
      return
    end
    
    success = @inventory_item.transfer_stock(destination_location_id, amount, current_user.id, params[:notes])
    
    respond_to do |format|
      if success
        format.html { redirect_back(fallback_location: inventory_path, notice: "Inventory successfully transferred.") }
        format.json { render json: @inventory_item }
      else
        format.html { redirect_back(fallback_location: inventory_path, alert: "Failed to transfer inventory.") }
        format.json { render json: { error: "Failed to transfer inventory." }, status: :unprocessable_entity }
      end
    end
  end
  
  def report
    authorize :inventory, :report?
    
    @locations = policy_scope(Location).order(name: :asc)
    
    @total_products = policy_scope(Product).count
    @total_items = policy_scope(InventoryItem).sum(:quantity)
    @total_value = policy_scope(InventoryItem).joins(:product).sum('inventory_items.quantity * products.cost_price')
    
    @low_stock_count = policy_scope(Product).low_stock.count
    @out_of_stock_count = policy_scope(Product).out_of_stock.count
    
    if params[:report_type] == 'by_location'
      @location_report = policy_scope(Location)
                         .left_joins(inventory_items: :product)
                         .group('locations.id')
                         .select('locations.*, COUNT(DISTINCT products.id) as product_count, SUM(inventory_items.quantity) as total_quantity, SUM(inventory_items.quantity * products.cost_price) as total_value')
                         .order('locations.name ASC')
    elsif params[:report_type] == 'by_category'
      @category_report = policy_scope(Product)
                         .where.not(category: [nil, ''])
                         .left_joins(:inventory_items)
                         .group('products.category')
                         .select('products.category, COUNT(DISTINCT products.id) as product_count, SUM(inventory_items.quantity) as total_quantity, SUM(inventory_items.quantity * products.cost_price) as total_value')
                         .order('products.category ASC')
    end
    
    respond_to do |format|
      format.html
      format.json { render json: { 
        total_products: @total_products,
        total_items: @total_items,
        total_value: @total_value,
        low_stock_count: @low_stock_count,
        out_of_stock_count: @out_of_stock_count,
        location_report: @location_report,
        category_report: @category_report
      } }
    end
  end
  
  private
  
  def set_inventory_item
    @inventory_item = InventoryItem.find(params[:id])
  end
end