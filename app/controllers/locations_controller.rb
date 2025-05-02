class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :edit, :update, :destroy]
  
  def index
    @locations = policy_scope(Location).includes(:parent_location).order(created_at: :desc)
    
    respond_to do |format|
      format.html
      format.json { render json: @locations }
    end
  end
  
  def show
    authorize @location
    
    respond_to do |format|
      format.html
      format.json { render json: @location }
    end
  end
  
  def new
    @location = Location.new
    authorize @location
    
    # Get parent location if provided
    @parent_location = Location.find(params[:parent_id]) if params[:parent_id].present?
  end
  
  def edit
    authorize @location
  end
  
  def create
    @location = Location.new(location_params)
    authorize @location
    
    respond_to do |format|
      if @location.save
        format.html { redirect_to location_path(@location), notice: "Location was successfully created." }
        format.json { render json: @location, status: :created }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @location.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    authorize @location
    
    respond_to do |format|
      if @location.update(location_params)
        format.html { redirect_to location_path(@location), notice: "Location was successfully updated." }
        format.json { render json: @location }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @location.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    authorize @location
    
    respond_to do |format|
      if @location.destroy
        format.html { redirect_to locations_path, notice: "Location was successfully deleted." }
        format.json { head :no_content }
      else
        format.html { redirect_to locations_path, alert: "Could not delete location." }
        format.json { render json: { errors: ["Could not delete location"] }, status: :unprocessable_entity }
      end
    end
  end
  
  private
  
  def set_location
    @location = Location.find(params[:id])
  end
  
  def location_params
    params.require(:location).permit(
      :name,
      :address,
      :city,
      :state, 
      :postal_code,
      :country,
      :phone,
      :email,
      :notes,
      :active,
      :location_type,
      :parent_location_id
    )
  end
end