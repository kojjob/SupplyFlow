module Api
  module V1
    class InventoryController < Api::V1::BaseController
      before_action :set_inventory_item, only: [ :show, :update ]
      before_action :set_product_and_location, only: [ :index ]

      # GET /api/v1/inventory?product_id=1&location_id=2
      # Get inventory information for a specific product and location
      def index
        # Check if we have a product and location
        if @product && @location
          # Authorization check
          authorize @product, :show?
          authorize @location, :show?

          # Find or initialize inventory item
          @inventory_item = InventoryItem.find_or_initialize_by(
            product_id: @product.id,
            location_id: @location.id
          )

          # Get all available locations for transfers (that the user has access to)
          @locations = policy_scope(Location).where.not(id: @location.id).order(:name)

          api_response({
            product: {
              id: @product.id,
              name: @product.name,
              sku: @product.sku,
              category: @product.category,
              unit_of_measure: @product.unit_of_measure || "units",
              reorder_point: @product.reorder_point,
              minimum_stock_level: @product.minimum_stock_level
            },
            location: {
              id: @location.id,
              name: @location.name,
              address: @location.address,
              location_type: @location.location_type
            },
            inventory: {
              id: @inventory_item.id,
              quantity: @inventory_item.quantity || 0,
              reserved_quantity: @inventory_item.reserved_quantity || 0,
              available_quantity: @inventory_item.available_quantity || 0,
              status: @inventory_item.status || "available",
              new_record: @inventory_item.new_record?,
              lot_number: @inventory_item.lot_number,
              serial_number: @inventory_item.serial_number,
              expiry_date: @inventory_item.expiry_date,
              last_updated: @inventory_item.updated_at
            },
            available_locations: @locations.map { |loc|
              {
                id: loc.id,
                name: loc.name,
                location_type: loc.location_type
              }
            },
            can_adjust: current_user.can_adjust_stock?,
            can_transfer: current_user.can_transfer_stock?
          })
        else
          # Handle the case where either product or location is missing
          api_error("Both product_id and location_id are required", :bad_request)
        end
      end

      # GET /api/v1/inventory/:id
      # Get detailed information about a specific inventory item
      def show
        authorize @inventory_item.product, :show?
        authorize @inventory_item.location, :show?

        # Get recent transactions for this inventory item
        recent_transactions = InventoryTransaction.where(
          product_id: @inventory_item.product_id,
          source_location_id: @inventory_item.location_id
        ).or(
          InventoryTransaction.where(
            product_id: @inventory_item.product_id,
            destination_location_id: @inventory_item.location_id
          )
        ).order(created_at: :desc).limit(10)

        api_response({
          inventory_item: @inventory_item.as_json(
            include: {
              product: { only: [ :id, :name, :sku, :unit_of_measure, :category, :barcode ] },
              location: { only: [ :id, :name, :address, :location_type ] }
            },
            methods: [ :available_quantity ]
          ),
          transactions: recent_transactions.as_json(
            include: {
              user: { only: [ :id, :name ] },
              source_location: { only: [ :id, :name ] },
              destination_location: { only: [ :id, :name ] }
            }
          ),
          can_adjust: current_user.can_adjust_stock?,
          can_transfer: current_user.can_transfer_stock?
        })
      end

      # POST /api/v1/inventory
      # Add inventory to a location
      def create
        # Authorization check
        authorize :inventory, :adjust?

        # Validate parameters
        unless params[:product_id].present? && params[:location_id].present? && params[:quantity].present?
          return api_error("Missing required parameters: product_id, location_id, and quantity are required", :bad_request)
        end

        # Get product and location
        begin
          product = Product.find(params[:product_id])
          location = Location.find(params[:location_id])
        rescue ActiveRecord::RecordNotFound => e
          return api_error("Invalid product or location: #{e.message}", :not_found)
        end

        # Authorize access to both resources
        authorize product, :show?
        authorize location, :show?

        # Get or create inventory item
        @inventory_item = InventoryItem.find_or_initialize_by(
          product_id: product.id,
          location_id: location.id
        )

        # Set organization for new records
        @inventory_item.organization_id = current_user.organization_id if @inventory_item.new_record?

        # Get quantity to add
        quantity = params[:quantity].to_i

        # Validate quantity
        if quantity <= 0
          return api_error("Quantity must be greater than zero", :unprocessable_entity)
        end

        # Set additional attributes if provided
        @inventory_item.lot_number = params[:lot_number] if params[:lot_number].present?
        @inventory_item.serial_number = params[:serial_number] if params[:serial_number].present?
        @inventory_item.expiry_date = params[:expiry_date] if params[:expiry_date].present?

        # Add stock and create transaction
        if @inventory_item.add_stock(quantity, params[:transaction_type] || "stock_addition", current_user.id, params[:notes])
          api_response({
            success: true,
            inventory_item: @inventory_item.as_json(methods: [ :available_quantity ]),
            message: "Added #{quantity} items to inventory"
          }, :created)
        else
          api_error(@inventory_item.errors.full_messages, :unprocessable_entity)
        end
      end

      # PATCH/PUT /api/v1/inventory/:id
      # Update inventory (remove stock)
      def update
        # Authorization check
        authorize :inventory, :adjust?
        authorize @inventory_item.product, :show?
        authorize @inventory_item.location, :show?

        # Determine the action type
        case params[:action_type]
        when "remove"
          # Remove stock
          quantity = params[:quantity].to_i

          # Validate quantity
          if quantity <= 0
            return api_error("Quantity must be greater than zero", :unprocessable_entity)
          end

          if @inventory_item.remove_stock(quantity, params[:transaction_type] || "stock_removal", current_user.id, params[:notes])
            api_response({
              success: true,
              inventory_item: @inventory_item.reload.as_json(methods: [ :available_quantity ]),
              message: "Removed #{quantity} items from inventory"
            })
          else
            api_error("Cannot remove more than available quantity", :unprocessable_entity)
          end
        when "adjust"
          # Adjust stock to a specific level
          new_quantity = params[:quantity].to_i

          # Validate quantity
          if new_quantity < 0
            return api_error("Quantity cannot be negative", :unprocessable_entity)
          end

          current_quantity = @inventory_item.quantity || 0
          difference = new_quantity - current_quantity

          if difference > 0
            # Adding stock
            if @inventory_item.add_stock(difference, "stock_adjustment", current_user.id, params[:notes])
              api_response({
                success: true,
                inventory_item: @inventory_item.reload.as_json(methods: [ :available_quantity ]),
                message: "Adjusted inventory to #{new_quantity} items (added #{difference})"
              })
            else
              api_error(@inventory_item.errors.full_messages, :unprocessable_entity)
            end
          elsif difference < 0
            # Removing stock
            if @inventory_item.remove_stock(difference.abs, "stock_adjustment", current_user.id, params[:notes])
              api_response({
                success: true,
                inventory_item: @inventory_item.reload.as_json(methods: [ :available_quantity ]),
                message: "Adjusted inventory to #{new_quantity} items (removed #{difference.abs})"
              })
            else
              api_error("Cannot remove more than available quantity", :unprocessable_entity)
            end
          else
            # No change needed
            api_response({
              success: true,
              inventory_item: @inventory_item.as_json(methods: [ :available_quantity ]),
              message: "No adjustment needed, quantity remains at #{current_quantity}"
            })
          end
        else
          api_error("Unknown action type. Use 'remove' or 'adjust'", :bad_request)
        end
      end

      # POST /api/v1/inventory/transfer
      # Transfer inventory between locations
      def transfer
        # Authorization check
        authorize :inventory, :transfer?

        # Validate parameters
        unless params[:source_location_id].present? && params[:destination_location_id].present? &&
               params[:product_id].present? && params[:quantity].present?
          return api_error("Missing required parameters: source_location_id, destination_location_id, product_id, and quantity are required", :bad_request)
        end

        source_location_id = params[:source_location_id]
        destination_location_id = params[:destination_location_id]
        product_id = params[:product_id]
        quantity = params[:quantity].to_i

        # Validate quantity
        if quantity <= 0
          return api_error("Quantity must be greater than zero", :unprocessable_entity)
        end

        # Get source and destination locations
        begin
          source_location = Location.find(source_location_id)
          destination_location = Location.find(destination_location_id)
          product = Product.find(product_id)
        rescue ActiveRecord::RecordNotFound => e
          return api_error("Invalid location or product: #{e.message}", :not_found)
        end

        # Authorize access to resources
        authorize source_location, :show?
        authorize destination_location, :show?
        authorize product, :show?

        # Find source inventory item
        @source_inventory = InventoryItem.find_or_initialize_by(
          product_id: product_id,
          location_id: source_location_id
        )

        # Check if source has enough quantity
        if @source_inventory.available_quantity < quantity
          return api_error("Not enough available quantity for transfer. Available: #{@source_inventory.available_quantity}, Requested: #{quantity}", :unprocessable_entity)
        end

        # Perform transfer
        if @source_inventory.transfer_stock(destination_location_id, quantity, current_user.id, params[:notes])
          # Get the updated inventory items for both source and destination
          source_after = InventoryItem.find_by(product_id: product_id, location_id: source_location_id)
          destination_after = InventoryItem.find_by(product_id: product_id, location_id: destination_location_id)

          api_response({
            success: true,
            message: "Successfully transferred #{quantity} items from #{source_location.name} to #{destination_location.name}",
            source: source_after&.as_json(methods: [ :available_quantity ]),
            destination: destination_after&.as_json(methods: [ :available_quantity ])
          })
        else
          api_error(@source_inventory.errors.full_messages, :unprocessable_entity)
        end
      end

      private

      def set_inventory_item
        @inventory_item = InventoryItem.find(params[:id])
      end

      def set_product_and_location
        @product = Product.find_by(id: params[:product_id]) if params[:product_id].present?
        @location = Location.find_by(id: params[:location_id]) if params[:location_id].present?
      end
    end
  end
end
