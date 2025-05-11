module Api
  module V1
    class SalesOrdersController < Api::V1::BaseController
      before_action :set_sales_order, only: [ :show, :update, :ship_items, :cancel, :payments ]

      # GET /api/v1/sales_orders
      # Returns a list of sales orders with pagination and filters
      def index
        @sales_orders = policy_scope(SalesOrder)

        # Filter by customer
        @sales_orders = @sales_orders.where(customer_id: params[:customer_id]) if params[:customer_id].present?

        # Filter by status
        @sales_orders = @sales_orders.where(status: params[:status]) if params[:status].present?

        # Filter by payment status
        @sales_orders = @sales_orders.where(payment_status: params[:payment_status]) if params[:payment_status].present?

        # Filter by date range
        if params[:start_date].present? && params[:end_date].present?
          @sales_orders = @sales_orders.where(order_date: Date.parse(params[:start_date])..Date.parse(params[:end_date]))
        elsif params[:start_date].present?
          @sales_orders = @sales_orders.where("order_date >= ?", Date.parse(params[:start_date]))
        elsif params[:end_date].present?
          @sales_orders = @sales_orders.where("order_date <= ?", Date.parse(params[:end_date]))
        end

        # Search by order number
        if params[:search].present?
          @sales_orders = @sales_orders.where("order_number LIKE ?", "%#{params[:search]}%")
        end

        # Sort by date descending by default
        @sales_orders = @sales_orders.order(order_date: :desc, created_at: :desc)

        @paginated_orders = paginate(@sales_orders)

        api_response({
          sales_orders: @paginated_orders.as_json(
            include: {
              customer: { only: [ :id, :name ] },
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

      # GET /api/v1/sales_orders/:id
      # Returns detailed information about a specific sales order
      def show
        authorize @sales_order

        # Get payments for this order
        payments = @sales_order.payments.order(payment_date: :desc)

        # Calculate total paid amount
        total_paid = payments.sum(:amount)

        api_response({
          sales_order: @sales_order.as_json(
            include: {
              customer: { only: [ :id, :name, :email, :phone ] },
              user: { only: [ :id, :name ] },
              sales_order_items: {
                include: {
                  product: { only: [ :id, :name, :sku, :unit_of_measure ] }
                }
              }
            }
          ),
          payment_summary: {
            total_amount: @sales_order.total_amount,
            total_paid: total_paid,
            balance_due: @sales_order.total_amount - total_paid,
            payment_status: @sales_order.payment_status
          },
          recent_payments: payments.limit(5).as_json(
            only: [ :id, :payment_number, :payment_date, :amount, :payment_method, :reference_number ]
          ),
          can_edit: current_user.can_manage_sales_orders? && [ "draft", "confirmed" ].include?(@sales_order.status),
          can_process: current_user.can_manage_sales_orders? && @sales_order.status == "confirmed",
          can_ship: current_user.can_manage_inventory? && @sales_order.status == "processing",
          can_cancel: current_user.can_manage_sales_orders? && ![ "delivered", "cancelled" ].include?(@sales_order.status)
        })
      end

      # GET /api/v1/sales_orders/:id/payments
      # Returns payment information for a specific sales order
      def payments
        authorize @sales_order, :show?

        # Get all payments for this order
        payments = @sales_order.payments.order(payment_date: :desc)

        # Calculate total paid amount
        total_paid = payments.sum(:amount)

        api_response({
          sales_order: {
            id: @sales_order.id,
            order_number: @sales_order.order_number,
            order_date: @sales_order.order_date,
            customer_name: @sales_order.customer.name,
            total_amount: @sales_order.total_amount,
            payment_status: @sales_order.payment_status
          },
          payment_summary: {
            total_amount: @sales_order.total_amount,
            total_paid: total_paid,
            balance_due: @sales_order.total_amount - total_paid
          },
          payments: payments.as_json(
            include: {
              user: { only: [ :id, :name ] }
            }
          ),
          can_add_payment: current_user.can_manage_payments? && ![ "cancelled", "refunded" ].include?(@sales_order.payment_status)
        })
      end

      # POST /api/v1/sales_orders
      # Create a new sales order
      def create
        authorize SalesOrder

        @sales_order = SalesOrder.new(sales_order_params)
        @sales_order.organization_id = current_user.organization_id
        @sales_order.user_id = current_user.id
        @sales_order.status = "draft"
        @sales_order.payment_status = "unpaid"

        # Generate order number if not provided
        if @sales_order.order_number.blank?
          last_so = SalesOrder.where(organization_id: current_user.organization_id)
                              .where("order_number LIKE ?", "SO-#{Date.today.year}-%")
                              .order(order_number: :desc)
                              .first

          number = last_so ? last_so.order_number.split("-").last.to_i + 1 : 1
          @sales_order.order_number = "SO-#{Date.today.year}-#{number.to_s.rjust(6, '0')}"
        end

        # Process items
        items_params = params[:sales_order][:items]

        begin
          ActiveRecord::Base.transaction do
            # Save the sales order
            @sales_order.save!

            # Add items if provided
            if items_params.present?
              items_params.each do |item_params|
                product = Product.find(item_params[:product_id])
                quantity = item_params[:quantity].to_i
                unit_price = item_params[:unit_price].to_f

                # Create the sales order item
                so_item = @sales_order.sales_order_items.build(
                  product_id: product.id,
                  quantity: quantity,
                  unit_price: unit_price,
                  tax_rate: item_params[:tax_rate] || 0,
                  discount_amount: item_params[:discount_amount] || 0,
                  total_amount: quantity * unit_price
                )

                so_item.save!
              end
            end

            # Calculate totals
            @sales_order.calculate_totals
            @sales_order.save!

            # Log activity
            UserActivity.create(
              user: current_user,
              organization_id: current_user.organization_id,
              action: "sales_order.created",
              details: { so_id: @sales_order.id, so_number: @sales_order.order_number }
            )

            api_response({ sales_order: @sales_order }, :created)
          end
        rescue ActiveRecord::RecordInvalid => e
          api_error(e.record.errors.full_messages, :unprocessable_entity)
        rescue => e
          api_error(e.message, :unprocessable_entity)
        end
      end

      # PATCH/PUT /api/v1/sales_orders/:id
      # Update a sales order (only draft and confirmed status)
      def update
        authorize @sales_order

        # Only allow updates for draft and confirmed status
        unless [ "draft", "confirmed" ].include?(@sales_order.status)
          return api_error("Cannot modify sales order in #{@sales_order.status} status", :unprocessable_entity)
        end

        begin
          ActiveRecord::Base.transaction do
            # Update basic attributes
            @sales_order.update!(sales_order_params)

            # Handle items if provided
            if params[:sales_order][:items].present?
              # Remove existing items if we're replacing them all
              if params[:replace_items].present? && params[:replace_items] == "true"
                @sales_order.sales_order_items.destroy_all
              end

              # Add or update items
              params[:sales_order][:items].each do |item_params|
                if item_params[:id].present?
                  # Update existing item
                  item = @sales_order.sales_order_items.find(item_params[:id])
                  item.update!(
                    quantity: item_params[:quantity],
                    unit_price: item_params[:unit_price],
                    tax_rate: item_params[:tax_rate] || item.tax_rate,
                    discount_amount: item_params[:discount_amount] || item.discount_amount,
                    total_amount: item_params[:quantity].to_i * item_params[:unit_price].to_f
                  )
                else
                  # Create new item
                  @sales_order.sales_order_items.create!(
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
                @sales_order.sales_order_items.find(item_id).destroy
              end
            end

            # Recalculate totals
            @sales_order.calculate_totals
            @sales_order.save!

            # Log activity
            UserActivity.create(
              user: current_user,
              organization_id: current_user.organization_id,
              action: "sales_order.updated",
              details: { so_id: @sales_order.id, so_number: @sales_order.order_number }
            )

            api_response({ sales_order: @sales_order })
          end
        rescue ActiveRecord::RecordInvalid => e
          api_error(e.record.errors.full_messages, :unprocessable_entity)
        rescue => e
          api_error(e.message, :unprocessable_entity)
        end
      end

      # POST /api/v1/sales_orders/:id/ship_items
      # Ship items for a sales order
      def ship_items
        authorize @sales_order, :update?

        # Only allow shipping for processing sales orders
        unless @sales_order.status == "processing"
          return api_error("Cannot ship items for sales order in #{@sales_order.status} status", :unprocessable_entity)
        end

        begin
          ActiveRecord::Base.transaction do
            # Get the source location
            location_id = params[:location_id]

            unless location_id.present?
              return api_error("Source location is required", :bad_request)
            end

            location = Location.find(location_id)
            authorize location, :show?

            # Process shipped items
            shipped_items = params[:shipped_items]
            all_shipped = true

            unless shipped_items.present?
              return api_error("Shipped items data is required", :bad_request)
            end

            shipped_items.each do |item_data|
              so_item = @sales_order.sales_order_items.find(item_data[:sales_order_item_id])
              shipped_quantity = item_data[:quantity].to_i

              # Validate quantity
              if shipped_quantity < 0
                return api_error("Shipped quantity cannot be negative", :unprocessable_entity)
              end

              if shipped_quantity > 0
                # Find inventory item at the source location
                inventory_item = InventoryItem.find_by(
                  organization_id: current_user.organization_id,
                  product_id: so_item.product_id,
                  location_id: location_id
                )

                # Check inventory availability
                if inventory_item.nil? || inventory_item.available_quantity < shipped_quantity
                  available = inventory_item ? inventory_item.available_quantity : 0
                  return api_error("Not enough inventory for #{so_item.product.name}. Available: #{available}, Requested: #{shipped_quantity}", :unprocessable_entity)
                end

                # Remove stock from inventory
                inventory_item.remove_stock(
                  shipped_quantity,
                  "sales_shipment",
                  current_user.id,
                  "Shipped for SO #{@sales_order.order_number}",
                  @sales_order
                )
              end

              # Update the shipped quantity on the sales order item
              so_item.shipped_quantity ||= 0
              so_item.shipped_quantity += shipped_quantity
              so_item.save!

              # Check if all items are shipped
              if so_item.shipped_quantity < so_item.quantity
                all_shipped = false
              end
            end

            # Update sales order status if all items shipped
            if all_shipped
              @sales_order.status = "shipped"
              @sales_order.shipping_date = Date.today
            end

            @sales_order.save!

            # Log activity
            UserActivity.create(
              user: current_user,
              organization_id: current_user.organization_id,
              action: "sales_order.items_shipped",
              details: {
                so_id: @sales_order.id,
                so_number: @sales_order.order_number,
                location_id: location_id,
                location_name: location.name
              }
            )

            api_response({
              sales_order: @sales_order,
              message: "Items shipped successfully",
              status_updated: all_shipped
            })
          end
        rescue ActiveRecord::RecordInvalid => e
          api_error(e.record.errors.full_messages, :unprocessable_entity)
        rescue => e
          api_error(e.message, :unprocessable_entity)
        end
      end

      # POST /api/v1/sales_orders/:id/cancel
      # Cancel a sales order
      def cancel
        authorize @sales_order, :update?

        # Only allow cancellation for draft, confirmed, or processing sales orders
        unless [ "draft", "confirmed", "processing" ].include?(@sales_order.status)
          return api_error("Cannot cancel sales order in #{@sales_order.status} status", :unprocessable_entity)
        end

        # Check if payments exist
        if @sales_order.payments.exists?
          return api_error("Cannot cancel sales order with payments. Refund payments first.", :unprocessable_entity)
        end

        @sales_order.status = "cancelled"

        if @sales_order.save
          # Log activity
          UserActivity.create(
            user: current_user,
            organization_id: current_user.organization_id,
            action: "sales_order.cancelled",
            details: { so_id: @sales_order.id, so_number: @sales_order.order_number }
          )

          api_response({
            sales_order: @sales_order,
            message: "Sales order cancelled successfully"
          })
        else
          api_error(@sales_order.errors.full_messages, :unprocessable_entity)
        end
      end

      private

      def set_sales_order
        @sales_order = SalesOrder.find(params[:id])
      end

      def sales_order_params
        params.require(:sales_order).permit(
          :customer_id, :order_number, :order_date, :shipping_date,
          :shipping_address, :billing_address, :notes
        )
      end
    end
  end
end
