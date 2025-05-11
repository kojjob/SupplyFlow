module Api
  module V1
    class SuppliersController < Api::V1::BaseController
      before_action :set_supplier, only: [ :show, :update, :destroy ]

      # GET /api/v1/suppliers
      # Returns a list of suppliers with pagination
      def index
        @suppliers = policy_scope(Supplier)

        # Apply filters
        if params[:search].present?
          search_term = "%#{params[:search].downcase}%"
          @suppliers = @suppliers.where("LOWER(name) LIKE :search OR LOWER(email) LIKE :search OR LOWER(phone) LIKE :search",
            search: search_term)
        end

        # Include inactive suppliers if requested and authorized
        @suppliers = @suppliers.active unless params[:include_inactive].present? && current_user.can_manage_suppliers?

        # Sort results
        sort_column = params[:sort] || "name"
        sort_direction = params[:direction] || "asc"

        if Supplier.column_names.include?(sort_column)
          @suppliers = @suppliers.order("#{sort_column} #{sort_direction}")
        else
          @suppliers = @suppliers.order(name: :asc)
        end

        @paginated_suppliers = paginate(@suppliers)

        api_response({
          suppliers: @paginated_suppliers.as_json(
            only: [ :id, :name, :contact_person, :email, :phone, :active ]
          ),
          pagination: {
            current_page: @paginated_suppliers.current_page,
            total_pages: @paginated_suppliers.total_pages,
            total_items: @paginated_suppliers.total_count,
            per_page: @paginated_suppliers.limit_value
          }
        })
      end

      # GET /api/v1/suppliers/:id
      # Returns detailed information about a specific supplier
      def show
        authorize @supplier

        # Get recent purchase orders for this supplier
        recent_orders = PurchaseOrder.where(supplier_id: @supplier.id)
                                   .order(order_date: :desc)
                                   .limit(5)

        api_response({
          supplier: @supplier,
          stats: {
            total_orders: PurchaseOrder.where(supplier_id: @supplier.id).count,
            total_spend: PurchaseOrder.where(supplier_id: @supplier.id).sum(:total_amount),
            pending_orders: PurchaseOrder.where(supplier_id: @supplier.id, status: [ "draft", "submitted", "approved" ]).count
          },
          recent_orders: recent_orders.map do |order|
            {
              id: order.id,
              order_number: order.order_number,
              order_date: order.order_date,
              status: order.status,
              total_amount: order.total_amount,
              items_count: order.purchase_order_items.count
            }
          end
        })
      end

      # POST /api/v1/suppliers
      # Create a new supplier
      def create
        authorize Supplier

        @supplier = Supplier.new(supplier_params)
        @supplier.organization_id = current_user.organization_id

        if @supplier.save
          # Record the activity
          UserActivity.create(
            user: current_user,
            organization_id: current_user.organization_id,
            action: "supplier.created",
            details: { supplier_id: @supplier.id, supplier_name: @supplier.name }
          )

          api_response({ supplier: @supplier }, :created)
        else
          api_error(@supplier.errors.full_messages, :unprocessable_entity)
        end
      end

      # PATCH/PUT /api/v1/suppliers/:id
      # Update a supplier
      def update
        authorize @supplier

        if @supplier.update(supplier_params)
          # Record the activity
          UserActivity.create(
            user: current_user,
            organization_id: current_user.organization_id,
            action: "supplier.updated",
            details: { supplier_id: @supplier.id, supplier_name: @supplier.name }
          )

          api_response({ supplier: @supplier })
        else
          api_error(@supplier.errors.full_messages, :unprocessable_entity)
        end
      end

      # DELETE /api/v1/suppliers/:id
      # Deactivate a supplier (soft delete)
      def destroy
        authorize @supplier

        # Check if supplier has associated purchase orders
        if PurchaseOrder.where(supplier_id: @supplier.id).exists?
          # Soft delete by deactivating
          if @supplier.update(active: false)
            UserActivity.create(
              user: current_user,
              organization_id: current_user.organization_id,
              action: "supplier.deactivated",
              details: { supplier_id: @supplier.id, supplier_name: @supplier.name }
            )

            api_response({
              message: "Supplier has been deactivated",
              deactivated: true
            })
          else
            api_error(@supplier.errors.full_messages, :unprocessable_entity)
          end
        else
          # Hard delete if no associated records
          if @supplier.destroy
            UserActivity.create(
              user: current_user,
              organization_id: current_user.organization_id,
              action: "supplier.deleted",
              details: { supplier_name: @supplier.name }
            )

            api_response({
              message: "Supplier has been deleted",
              deleted: true
            })
          else
            api_error(@supplier.errors.full_messages, :unprocessable_entity)
          end
        end
      end

      private

      def set_supplier
        @supplier = Supplier.find(params[:id])
      end

      def supplier_params
        params.require(:supplier).permit(
          :name, :contact_person, :email, :phone, :address, :city, :state,
          :postal_code, :country, :tax_id, :registration_number, :payment_terms,
          :credit_limit, :active, :notes
        )
      end
    end
  end
end
