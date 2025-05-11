class ProductsController < ApplicationController
  before_action :set_product, only: [ :show, :edit, :update, :destroy ]

  def index
    @products = policy_scope(Product)
                .includes(:inventory_items)
                .order(created_at: :desc)

    if params[:category].present?
      @products = @products.by_category(params[:category])
    end

    if params[:query].present?
      query = "%#{params[:query]}%"
      # Use LOWER() for case-insensitive search (works with PostgreSQL and SQLite)
      @products = @products.where("LOWER(name) LIKE LOWER(?) OR LOWER(sku) LIKE LOWER(?) OR LOWER(barcode) LIKE LOWER(?)",
                                 query,
                                 query,
                                 query)
    end

    if params[:stock_status] == "low_stock"
      @products = @products.low_stock
    elsif params[:stock_status] == "out_of_stock"
      @products = @products.out_of_stock
    end

    # For pagination - limit to 25 records without using Kaminari
    @total_count = @products.count

    # Debug params[:page]
    Rails.logger.debug "PAGINATION DEBUG: params[:page] = #{params[:page].inspect}, class = #{params[:page].class}"

    # Handle various edge cases
    page = if params[:page].nil?
      0
    elsif params[:page].is_a?(Hash)
      0
    elsif params[:page].to_s.strip.empty?
      0
    else
      params[:page].to_i
    end

    Rails.logger.debug "PAGINATION DEBUG: calculated page = #{page}"

    @products = @products.limit(25).offset(page * 25)

    respond_to do |format|
      format.html
      format.json { render json: @products }
    end
  end

  def show
    authorize @product
    @inventory_items = @product.inventory_items.includes(:location).order("locations.name ASC")
    @recent_transactions = @product.inventory_transactions.recent.includes(:user, :source_location, :destination_location).limit(10)

    respond_to do |format|
      format.html
      format.json { render json: @product }
    end
  end

  def new
    @product = Product.new
    authorize @product
  end

  def edit
    authorize @product
  end

  def create
    @product = Product.new(product_params)
    authorize @product

    respond_to do |format|
      if @product.save
        # Create inventory items for each location if specified
        if params[:initial_inventory].present?
          params[:initial_inventory].each do |location_id, quantity|
            next if quantity.blank? || quantity.to_i <= 0

            location = Location.find_by(id: location_id)
            next unless location

            inventory_item = InventoryItem.new(
              organization: @product.organization,
              product: @product,
              location: location,
              quantity: quantity.to_i
            )

            if inventory_item.save && current_user.present?
              InventoryTransaction.create(
                organization: @product.organization,
                product: @product,
                destination_location: location,
                user: current_user,
                transaction_type: "stock_addition",
                quantity: quantity.to_i,
                notes: "Initial inventory for new product"
              )
            end
          end
        end

        format.html { redirect_to product_path(@product), notice: "Product was successfully created." }
        format.json { render json: @product, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @product

    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to product_path(@product), notice: "Product was successfully updated." }
        format.json { render json: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @product

    respond_to do |format|
      if @product.inventory_items.sum(:quantity) > 0
        format.html { redirect_to product_path(@product), alert: "Cannot delete product with existing inventory." }
        format.json { render json: { error: "Cannot delete product with existing inventory." }, status: :unprocessable_entity }
      elsif @product.destroy
        format.html { redirect_to products_path, notice: "Product was successfully deleted." }
        format.json { head :no_content }
      else
        format.html { redirect_to product_path(@product), alert: "Could not delete product." }
        format.json { render json: { errors: [ "Could not delete product" ] }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name,
      :sku,
      :description,
      :barcode,
      :category,
      :brand,
      :model,
      :unit_of_measure,
      :cost_price,
      :selling_price,
      :weight,
      :length,
      :width,
      :height,
      :minimum_stock_level,
      :reorder_point,
      :active,
      :perishable,
      :expiry_date,
      :custom_fields,
      :metadata,
      gallery_images: [] # Changed from :main_image to allow multiple uploads
    )
  end
end
