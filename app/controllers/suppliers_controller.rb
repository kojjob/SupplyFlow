class SuppliersController < ApplicationController
  before_action :set_supplier, only: [ :show, :edit, :update, :destroy ]

  def index
    @suppliers = policy_scope(Supplier).order(name: :asc)

    if params[:query].present?
      query = "%#{params[:query]}%"
      @suppliers = @suppliers.where("LOWER(name) LIKE LOWER(?) OR LOWER(email) LIKE LOWER(?) OR LOWER(phone) LIKE LOWER(?)",
                                   query,
                                   query,
                                   query)
    end

    if params[:active].present?
      @suppliers = @suppliers.where(active: params[:active] == "true")
    end

    # For pagination - limit to 25 records without using Kaminari
    @total_count = @suppliers.count
    @suppliers = @suppliers.limit(25).offset((params[:page].to_i || 0) * 25)

    respond_to do |format|
      format.html
      format.json { render json: @suppliers }
    end
  end

  def show
    authorize @supplier

    @purchase_orders = @supplier.purchase_orders.order(created_at: :desc).limit(10)

    respond_to do |format|
      format.html
      format.json { render json: @supplier }
    end
  end

  def new
    @supplier = Supplier.new
    authorize @supplier
  end

  def edit
    authorize @supplier
  end

  def create
    @supplier = Supplier.new(supplier_params)
    authorize @supplier

    respond_to do |format|
      if @supplier.save
        format.html { redirect_to supplier_path(@supplier), notice: "Supplier was successfully created." }
        format.json { render json: @supplier, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @supplier.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @supplier

    respond_to do |format|
      if @supplier.update(supplier_params)
        format.html { redirect_to supplier_path(@supplier), notice: "Supplier was successfully updated." }
        format.json { render json: @supplier }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @supplier.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @supplier

    respond_to do |format|
      if @supplier.purchase_orders.any?
        format.html { redirect_to supplier_path(@supplier), alert: "Cannot delete supplier with associated purchase orders." }
        format.json { render json: { error: "Cannot delete supplier with associated purchase orders." }, status: :unprocessable_entity }
      elsif @supplier.destroy
        format.html { redirect_to suppliers_path, notice: "Supplier was successfully deleted." }
        format.json { head :no_content }
      else
        format.html { redirect_to supplier_path(@supplier), alert: "Failed to delete supplier." }
        format.json { render json: @supplier.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_supplier
    @supplier = Supplier.find(params[:id])
  end

  def supplier_params
    params.require(:supplier).permit(
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
      :registration_number,
      :payment_terms,
      :credit_limit,
      :active,
      :notes
    )
  end
end
