module Api
  module V1
    class LocationsController < Api::V1::BaseController
      before_action :set_location, only: [ :show ]

      # GET /api/v1/locations
      # Returns a list of locations
      def index
        @locations = policy_scope(Location)

        # Apply search filter if provided
        if params[:search].present?
          @locations = @locations.where("LOWER(name) LIKE :search OR LOWER(address) LIKE :search",
            search: "%#{params[:search].to_s.downcase}%")
        end

        # Filter by parent location if provided
        @locations = @locations.where(parent_location_id: params[:parent_id]) if params[:parent_id].present?

        # Filter by location type if provided
        @locations = @locations.where(location_type: params[:location_type]) if params[:location_type].present?

        # Active only by default, include inactive if requested and authorized
        @locations = @locations.active unless params[:include_inactive].present? && current_user.can_manage_locations?

        # Order by name by default
        @locations = @locations.order(:name)

        @paginated_locations = paginate(@locations)

        # Return locations with minimal data for selection
        api_response({
          locations: @paginated_locations.map { |location|
            {
              id: location.id,
              name: location.name,
              address: location.address,
              city: location.city,
              location_type: location.location_type,
              parent_id: location.parent_location_id,
              parent_name: location.parent_location&.name,
              has_children: location.child_locations.any?
            }
          },
          pagination: {
            current_page: @paginated_locations.current_page,
            total_pages: @paginated_locations.total_pages,
            total_items: @paginated_locations.total_count,
            per_page: @paginated_locations.limit_value
          }
        })
      end

      # GET /api/v1/locations/:id
      # Returns detailed information about a specific location
      def show
        authorize @location

        # Get inventory items at this location
        inventory_items = @location.inventory_items.includes(:product)

        # Calculate total items
        total_items = inventory_items.count
        total_quantity = inventory_items.sum(:quantity)
        total_value = @location.inventory_value

        # Get categories of products at this location
        categories = inventory_items.joins(:product)
                               .select("DISTINCT products.category")
                               .pluck("products.category")
                               .compact

        # Get low stock and out of stock counts
        low_stock_count = @location.low_stock_items.count
        out_of_stock_count = @location.out_of_stock_items.count

        api_response({
          location: @location.as_json(
            include: {
              parent_location: { only: [ :id, :name ] },
              child_locations: { only: [ :id, :name ] }
            }
          ),
          stats: {
            total_items: total_items,
            total_quantity: total_quantity,
            total_value: total_value,
            categories: categories,
            low_stock_count: low_stock_count,
            out_of_stock_count: out_of_stock_count
          },
          inventory_summary: inventory_items.order(quantity: :desc).limit(10).map do |item|
            {
              id: item.id,
              product_id: item.product_id,
              product_name: item.product.name,
              product_sku: item.product.sku,
              category: item.product.category,
              unit_of_measure: item.product.unit_of_measure,
              quantity: item.quantity,
              available_quantity: item.available_quantity,
              reserved_quantity: item.reserved_quantity,
              status: item.status
            }
          end,
          recent_transactions: InventoryTransaction.where("source_location_id = ? OR destination_location_id = ?", @location.id, @location.id)
                                                  .order(created_at: :desc)
                                                  .includes(:product, :user)
                                                  .limit(5)
                                                  .map do |transaction|
            {
              id: transaction.id,
              date: transaction.created_at,
              type: transaction.transaction_type,
              product_name: transaction.product.name,
              quantity: transaction.quantity,
              user: transaction.user&.name,
              source: transaction.source_location&.name,
              destination: transaction.destination_location&.name
            }
          end
        })
      end

      private

      def set_location
        @location = Location.find(params[:id])
      end
    end
  end
end
