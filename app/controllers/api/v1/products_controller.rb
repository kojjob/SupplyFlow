module Api
  module V1
    class ProductsController < Api::V1::BaseController
      before_action :set_product, only: [ :show, :inventory ]

      # GET /api/v1/products
      # Returns a list of products with pagination
      def index
        @products = policy_scope(Product)

        # Apply filters
        @products = @products.where("LOWER(name) LIKE :search OR LOWER(sku) LIKE :search OR LOWER(category) LIKE :search",
          search: "%#{params[:search].to_s.downcase}%") if params[:search].present?
        @products = @products.by_category(params[:category]) if params[:category].present?

        # Include inactive products if requested and authorized
        @products = @products.active unless params[:include_inactive].present? && current_user.can_manage_products?

        # Apply stock status filters
        case params[:stock_status]
        when "low_stock"
          @products = @products.low_stock
        when "out_of_stock"
          @products = @products.out_of_stock
        end

        # Sort results
        if params[:sort].present?
          sort_field = params[:sort].start_with?("-") ? params[:sort][1..-1] : params[:sort]
          sort_dir = params[:sort].start_with?("-") ? :desc : :asc

          if Product.column_names.include?(sort_field)
            @products = @products.order(sort_field => sort_dir)
          end
        else
          @products = @products.order(name: :asc)
        end

        # Pagination
        @paginated_products = paginate(@products)

        api_response({
          products: @paginated_products.as_json(methods: [ :total_quantity, :available_quantity ]),
          pagination: {
            current_page: @paginated_products.current_page,
            total_pages: @paginated_products.total_pages,
            total_items: @paginated_products.total_count,
            per_page: @paginated_products.limit_value,
            start_item: @paginated_products.offset_value + 1,
            end_item: [ @paginated_products.offset_value + @paginated_products.limit_value, @paginated_products.total_count ].min
          }
        })
      end

      # GET /api/v1/products/:id
      # Returns detailed information about a specific product
      def show
        authorize @product

        render json: {
          id: @product.id,
          name: @product.name,
          sku: @product.sku,
          cost_price: @product.cost_price,
          selling_price: @product.selling_price,
          available_quantity: @product.available_quantity
        }


        api_response(@product.as_json(
          methods: [ :total_quantity, :available_quantity, :reserved_quantity, :low_stock?, :out_of_stock?, :profit_margin ],
          include: { inventory_items: { methods: [ :available_quantity ], include: { location: { only: [ :id, :name, :address ] } } } }
        ))
      end

      # GET /api/v1/products/:id/inventory
      # Returns detailed inventory information for a product
      def inventory
        authorize @product, :show?

        # Get inventory items with locations
        inventory_items = @product.inventory_items.includes(:location)

        # Calculate totals
        total_quantity = inventory_items.sum(:quantity)
        available_quantity = inventory_items.sum("quantity - reserved_quantity")
        reserved_quantity = inventory_items.sum(:reserved_quantity)

        api_response({
          product: {
            id: @product.id,
            name: @product.name,
            sku: @product.sku,
            category: @product.category,
            unit_of_measure: @product.unit_of_measure,
            reorder_point: @product.reorder_point,
            minimum_stock_level: @product.minimum_stock_level
          },
          totals: {
            total_quantity: total_quantity,
            available_quantity: available_quantity,
            reserved_quantity: reserved_quantity,
            low_stock: @product.low_stock?,
            out_of_stock: @product.out_of_stock?
          },
          inventory_items: inventory_items.map do |item|
            {
              id: item.id,
              location_id: item.location_id,
              location_name: item.location.name,
              quantity: item.quantity,
              available_quantity: item.available_quantity,
              reserved_quantity: item.reserved_quantity,
              status: item.status,
              last_updated: item.updated_at
            }
          end,
          transactions: @product.inventory_transactions.order(created_at: :desc).limit(5).map do |transaction|
            {
              id: transaction.id,
              transaction_type: transaction.transaction_type,
              quantity: transaction.quantity,
              source_location: transaction.source_location&.name,
              destination_location: transaction.destination_location&.name,
              created_at: transaction.created_at,
              user: transaction.user&.name || "System"
            }
          end
        })
      end

      private

      def set_product
        @product = Product.find(params[:id])
      end
    end
  end
end
