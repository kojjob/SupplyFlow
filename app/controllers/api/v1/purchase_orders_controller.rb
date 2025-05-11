module Api
  module V1
    class PurchaseOrdersController < Api::V1::BaseController
      before_action :set_purchase_order, only: [ :show, :update, :receive_items, :cancel ]

      # GET /api/v1/purchase_orders
      # Returns a list of purchase orders with pagination and filters
      def index
        @purchase_orders = policy_scope(PurchaseOrder)

        # Filter by supplier
        @purchase_orders = @purchase_orders.where(supplier_id: params[:supplier_id]) if params[:supplier_id].present?

        # Filter by status
        @purchase_orders = @purchase_orders.where(status: params[:status]) if params[:status].present?

        # Filter by date range
        if params[:start_date].present? && params[:end_date].present?
          @purchase_orders = @purchase_orders.where(order_date: Date.parse(params[:start_date])..Date.parse(params[:end_date]))
        elsif params[:start_date].present?
          @purchase_orders = @purchase_orders.where("order_date >= ?", Date.parse(params[:start_date]))
        elsif params[:end_date].present?
          @purchase_orders = @purchase_orders.where("order_date <= ?", Date.parse(params[:end_date]))
        end

        # Search by order number
        if params[:search].present?
          @purchase_orders = @purchase_orders.where("order_number LIKE ?", "%#{params[:search]}%")
        end

        # Sort by date descending by default
        @purchase_orders = @purchase_orders.order(order_date: :desc, created_at: :desc)

        @paginated_orders = paginate(@purchase_orders)

        api_response({
          purchase_orders: @paginated_orders.as_json(
            include: {
              supplier: { only: [ :id, :name ] },
              user: { only: [ :id, :name ] }
            }
          ),
          pagination: {
            current_page: @paginated_orders.current_page,
            total_pages: @paginated_orders.total_pages,
            total_items: @paginated_orders.total_count,
            per_page: @paginated_orders.limit_value
          }
        })
      end

      # GET /api/v1/purchase_orders/:id
      # Returns detailed information about a specific purchase order
      def show
        authorize @purchase_order

        api_response({
          purchase_order: @purchase_order.as_json(
            include: {
              supplier: { only: [ :id, :name, :email, :phone ] },
              user: { only: [ :id, :name ] },
              purchase_order_items: {
                include: {
                  product: { only: [ :id, :name, :sku, :unit_of_measure ] }
                }
              }
            }
          ),
          can_edit: current_user.can_manage_purchase_orders? && [ "draft", "submitted" ].include?(@purchase_order.status),
          can_approve: current_user.admin? && @purchase_order.status == "submitted",
          can_receive: current_user.can_manage_inventory? && @purchase_order.status == "approved",
          can_cancel: current_user.can_manage_purchase_orders? && ![ "received", "cancelled" ].include?(@purchase_order.status)
        })
      end

      # POST /api/v1/purchase_orders
      # Create a new purchase order
      def create
        authorize PurchaseOrder

        @purchase_order = PurchaseOrder.new(purchase_order_params)
        @purchase_order.organization_id = current_user.organization_id
        @purchase_order.user_id = current_user.id
        @purchase_order.status = "draft"

        # Generate order number if not provided
        if @purchase_order.order_number.blank?
          last_po = PurchaseOrder.where(organization_id: current_user.organization_id)
                                .where("order_number LIKE ?", "PO-#{Date.today.year}-%")
                                .order(order_number: :desc)
                                .first

          number = last_po ? last_po.order_number.split("-").last.to_i + 1 : 1
          @purchase_order.order_number = "PO-#{Date.today.year}-#{number.to_s.rjust(6, '0')}"
        end

        # Process items
        items_params = params[:purchase_order][:items]

        begin
          ActiveRecord::Base.transaction do
            # Save the purchase order
            @purchase_order.save!

            # Add items if provided
            if items_params.present?
              items_params.each do |item_params|
                product = Product.find(item_params[:product_id])
                quantity = item_params[:quantity].to_i
                unit_price = item_params[:unit_price].to_f

                # Create the purchase order item
                po_item = @purchase_order.purchase_order_items.build(
                  product_id: product.id,
                  quantity: quantity,
                  unit_price: unit_price,
                  tax_rate: item_params[:tax_rate] || 0,
                  discount_amount: item_params[:discount_amount] || 0,
                  total_amount: quantity * unit_price
                )

                po_item.save!
              end
            end

            # Calculate totals
            @purchase_order.calculate_totals
            @purchase_order.save!

            # Log activity
            UserActivity.create(
              user: current_user,
              organization_id: current_user.organization_id,
              action: "purchase_order.created",
              details: { po_id: @purchase_order.id, po_number: @purchase_order.order_number }
            )

            api_response({ purchase_order: @purchase_order }, :created)
          end
        rescue ActiveRecord::RecordInvalid => e
          api_error(e.record.errors.full_messages, :unprocessable_entity)
        rescue => e
          api_error(e.message, :unprocessable_entity)
        end
      end

      # PATCH/PUT /api/v1/purchase_orders/:id
      # Update a purchase order (only draft and submitted status)
      def update
        authorize @purchase_order

        # Only allow updates for draft and submitted status
        unless [ "draft", "submitted" ].include?(@purchase_order.status)
          return api_error("Cannot modify purchase order in #{@purchase_order.status} status", :unprocessable_entity)
        end

        begin
          ActiveRecord::Base.transaction do
            # Update basic attributes
            @purchase_order.update!(purchase_order_params)

            # Handle items if provided
            if params[:purchase_order][:items].present?
              # Remove existing items if we're replacing them all
              if params[:replace_items].present? && params[:replace_items] == "true"
                @purchase_order.purchase_order_items.destroy_all
              end

              # Add or update items
              params[:purchase_order][:items].each do |item_params|
                if item_params[:id].present?
                  # Update existing item
                  item = @purchase_order.purchase_order_items.find(item_params[:id])
                  item.update!(
                    quantity: item_params[:quantity],
                    unit_price: item_params[:unit_price],
                    tax_rate: item_params[:tax_rate] || item.tax_rate,
                    discount_amount: item_params[:discount_amount] || item.discount_amount,
                    total_amount: item_params[:quantity].to_i * item_params[:unit_price].to_f
                  )
                else
                  # Create new item
                  @purchase_order.purchase_order_items.create!(
                    product_id: item_params[:product_id],
                    quantity: item_params[:quantity],
                    unit_price: item_params[:unit_price],
                    tax_rate: item_params[:tax_rate] || 0,
                    discount_amount: item_params[:discount_amount] || 0,
                    total_amount: item_params[:quantity].to_i * item_params[:unit_price].to_f
                  )
                end
              end
            end

            # Remove specific items if requested
            if params[:remove_items].present?
              params[:remove_items].each do |item_id|
                @purchase_order.purchase_order_items.find(item_id).destroy
              end
            end

            # Recalculate totals
            @purchase_order.calculate_totals
            @purchase_order.save!

            # Log activity
            UserActivity.create(
              user: current_user,
              organization_id: current_user.organization_id,
              action: "purchase_order.updated",
              details: { po_id: @purchase_order.id, po_number: @purchase_order.order_number }
            )

            api_response({ purchase_order: @purchase_order })
          end
        rescue ActiveRecord::RecordInvalid => e
          api_error(e.record.errors.full_messages, :unprocessable_entity)
        rescue => e
          api_error(e.message, :unprocessable_entity)
        end
      end

      # POST /api/v1/purchase_orders/:id/receive_items
      # Receive items for a purchase order
      def receive_items
        authorize @purchase_order, :update?

        # Only allow receiving for approved purchase orders
        unless @purchase_order.status == "approved"
          return api_error("Cannot receive items for purchase order in #{@purchase_order.status} status", :unprocessable_entity)
        end

        begin
          ActiveRecord::Base.transaction do
            # Get the destination location
            location_id = params[:location_id]

            unless location_id.present?
              return api_error("Destination location is required", :bad_request)
            end

            location = Location.find(location_id)
            authorize location, :show?

            # Process received items
            received_items = params[:received_items]
            all_received = true

            unless received_items.present?
              return api_error("Received items data is required", :bad_request)
            end

            received_items.each do |item_data|
              po_item = @purchase_order.purchase_order_items.find(item_data[:purchase_order_item_id])
              received_quantity = item_data[:quantity].to_i

              # Validate quantity
              if received_quantity < 0
                return api_error("Received quantity cannot be negative", :unprocessable_entity)
              end

              # Find or create inventory item
              inventory_item = InventoryItem.find_or_initialize_by(
                organization_id: current_user.organization_id,
                product_id: po_item.product_id,
                location_id: location_id
              )

              # Add stock to inventory
              if received_quantity > 0
                inventory_item.add_stock(
                  received_quantity,
                  "purchase_receipt",
                  current_user.id,
                  "Received from PO #{@purchase_order.order_number}",
                  @purchase_order
                )
              end

              # Update the received quantity on the purchase order item
              po_item.received_quantity ||= 0
              po_item.received_quantity += received_quantity
              po_item.save!

              # Check if all items are received
              if po_item.received_quantity < po_item.quantity
                all_received = false
              end
            end

            # Update purchase order status if all items received
            if all_received
              @purchase_order.status = "received"
              @purchase_order.delivery_date = Date.today
            end

            @purchase_order.save!

            # Log activity
            UserActivity.create(
              user: current_user,
              organization_id: current_user.organization_id,
              action: "purchase_order.items_received",
              details: {
                po_id: @purchase_order.id,
                po_number: @purchase_order.order_number,
                location_id: location_id,
                location_name: location.name
              }
            )

            api_response({
              purchase_order: @purchase_order,
              message: "Items received successfully",
              status_updated: all_received
            })
          end
        rescue ActiveRecord::RecordInvalid => e
          api_error(e.record.errors.full_messages, :unprocessable_entity)
        rescue => e
          api_error(e.message, :unprocessable_entity)
        end
      end

      # POST /api/v1/purchase_orders/:id/cancel
      # Cancel a purchase order
      def cancel
        authorize @purchase_order, :update?

        # Only allow cancellation for draft, submitted, or approved purchase orders
        unless [ "draft", "submitted", "approved" ].include?(@purchase_order.status)
          return api_error("Cannot cancel purchase order in #{@purchase_order.status} status", :unprocessable_entity)
        end

        @purchase_order.status = "cancelled"

        if @purchase_order.save
          # Log activity
          UserActivity.create(
            user: current_user,
            organization_id: current_user.organization_id,
            action: "purchase_order.cancelled",
            details: { po_id: @purchase_order.id, po_number: @purchase_order.order_number }
          )

          api_response({
            purchase_order: @purchase_order,
            message: "Purchase order cancelled successfully"
          })
        else
          api_error(@purchase_order.errors.full_messages, :unprocessable_entity)
        end
      end

      private

      def set_purchase_order
        @purchase_order = PurchaseOrder.find(params[:id])
      end

      def purchase_order_params
        params.require(:purchase_order).permit(
          :supplier_id, :order_number, :order_date, :expected_delivery_date,
          :shipping_address, :billing_address, :status, :notes
        )
      end
    end
  end
end
