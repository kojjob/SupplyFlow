module Api
  module V1
    class CustomersController < Api::V1::BaseController
      before_action :set_customer, only: [ :show, :update, :destroy ]

      # GET /api/v1/customers
      # Returns a list of customers with pagination
      def index
        @customers = policy_scope(Customer)

        # Apply filters
        if params[:search].present?
          search_term = "%#{params[:search].downcase}%"
          @customers = @customers.where("LOWER(name) LIKE :search OR LOWER(email) LIKE :search OR LOWER(phone) LIKE :search",
            search: search_term)
        end

        # Include inactive customers if requested and authorized
        @customers = @customers.active unless params[:include_inactive].present? && current_user.can_manage_customers?

        # Sort results
        sort_column = params[:sort] || "name"
        sort_direction = params[:direction] || "asc"

        if Customer.column_names.include?(sort_column)
          @customers = @customers.order("#{sort_column} #{sort_direction}")
        else
          @customers = @customers.order(name: :asc)
        end

        @paginated_customers = paginate(@customers)

        api_response({
          customers: @paginated_customers.as_json(
            only: [ :id, :name, :contact_person, :email, :phone, :active ]
          ),
          pagination: {
            current_page: @paginated_customers.current_page,
            total_pages: @paginated_customers.total_pages,
            total_items: @paginated_customers.total_count,
            per_page: @paginated_customers.limit_value
          }
        })
      end

      # GET /api/v1/customers/:id
      # Returns detailed information about a specific customer
      def show
        authorize @customer

        # Get recent sales orders for this customer
        recent_orders = SalesOrder.where(customer_id: @customer.id)
                                 .order(order_date: :desc)
                                 .limit(5)

        # Calculate total revenue, outstanding balance, etc.
        total_revenue = SalesOrder.where(customer_id: @customer.id, status: [ "delivered" ]).sum(:total_amount)
        outstanding_balance = SalesOrder.where(customer_id: @customer.id, payment_status: [ "unpaid", "partially_paid" ]).sum(:total_amount) -
                              Payment.where(payable_type: "SalesOrder", payable_id: SalesOrder.where(customer_id: @customer.id).pluck(:id)).sum(:amount)

        api_response({
          customer: @customer,
          stats: {
            total_orders: SalesOrder.where(customer_id: @customer.id).count,
            total_revenue: total_revenue,
            outstanding_balance: outstanding_balance,
            pending_orders: SalesOrder.where(customer_id: @customer.id, status: [ "draft", "confirmed", "processing" ]).count
          },
          recent_orders: recent_orders.map do |order|
            {
              id: order.id,
              order_number: order.order_number,
              order_date: order.order_date,
              status: order.status,
              payment_status: order.payment_status,
              total_amount: order.total_amount,
              items_count: order.sales_order_items.count
            }
          end
        })
      end

      # POST /api/v1/customers
      # Create a new customer
      def create
        authorize Customer

        @customer = Customer.new(customer_params)
        @customer.organization_id = current_user.organization_id

        if @customer.save
          # Record the activity
          UserActivity.create(
            user: current_user,
            organization_id: current_user.organization_id,
            action: "customer.created",
            details: { customer_id: @customer.id, customer_name: @customer.name }
          )

          api_response({ customer: @customer }, :created)
        else
          api_error(@customer.errors.full_messages, :unprocessable_entity)
        end
      end

      # PATCH/PUT /api/v1/customers/:id
      # Update a customer
      def update
        authorize @customer

        if @customer.update(customer_params)
          # Record the activity
          UserActivity.create(
            user: current_user,
            organization_id: current_user.organization_id,
            action: "customer.updated",
            details: { customer_id: @customer.id, customer_name: @customer.name }
          )

          api_response({ customer: @customer })
        else
          api_error(@customer.errors.full_messages, :unprocessable_entity)
        end
      end

      # DELETE /api/v1/customers/:id
      # Deactivate a customer (soft delete)
      def destroy
        authorize @customer

        # Check if customer has associated sales orders
        if SalesOrder.where(customer_id: @customer.id).exists?
          # Soft delete by deactivating
          if @customer.update(active: false)
            UserActivity.create(
              user: current_user,
              organization_id: current_user.organization_id,
              action: "customer.deactivated",
              details: { customer_id: @customer.id, customer_name: @customer.name }
            )

            api_response({
              message: "Customer has been deactivated",
              deactivated: true
            })
          else
            api_error(@customer.errors.full_messages, :unprocessable_entity)
          end
        else
          # Hard delete if no associated records
          if @customer.destroy
            UserActivity.create(
              user: current_user,
              organization_id: current_user.organization_id,
              action: "customer.deleted",
              details: { customer_name: @customer.name }
            )

            api_response({
              message: "Customer has been deleted",
              deleted: true
            })
          else
            api_error(@customer.errors.full_messages, :unprocessable_entity)
          end
        end
      end

      private

      def set_customer
        @customer = Customer.find(params[:id])
      end

      def customer_params
        params.require(:customer).permit(
          :name, :contact_person, :email, :phone, :address, :city, :state,
          :postal_code, :country, :tax_id, :credit_limit, :active, :notes
        )
      end
    end
  end
end
