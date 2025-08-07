module Api
  module V1
    class ReportsController < BaseController
      before_action :authenticate_api_user!

      # GET /api/v1/reports/sales
      def sales
        authorize :report, :view_sales?

        # Get date range parameters
        start_date = params[:start_date] ? Date.parse(params[:start_date]) : 30.days.ago.to_date
        end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today

        # Get sales orders in date range
        sales_orders = SalesOrder.where(created_at: start_date.beginning_of_day..end_date.end_of_day)

        # Calculate sales metrics
        total_sales = sales_orders.sum(:total_amount)
        order_count = sales_orders.count
        average_order_value = order_count > 0 ? (total_sales / order_count).round(2) : 0

        # Get sales by status
        sales_by_status = sales_orders.group(:status).count

        # Get sales by day
        sales_by_day = sales_orders.group_by_day(:created_at, range: start_date.beginning_of_day..end_date.end_of_day)
                                  .sum(:total_amount)
                                  .transform_keys { |k| k.to_date.to_s }

        # Get top selling products
        top_products = SalesOrderItem.joins(:product, :sales_order)
                                     .where(sales_orders: { created_at: start_date.beginning_of_day..end_date.end_of_day })
                                     .group("products.id", "products.name")
                                     .select("products.id, products.name, SUM(sales_order_items.quantity) as total_quantity, SUM(sales_order_items.total_price) as total_revenue")
                                     .order("total_revenue DESC")
                                     .limit(10)
                                     .map do |item|
                                       {
                                         id: item.id,
                                         name: item.name,
                                         total_quantity: item.total_quantity,
                                         total_revenue: item.total_revenue
                                       }
                                     end

        render json: {
          report_type: "sales",
          date_range: {
            start_date: start_date,
            end_date: end_date
          },
          summary: {
            total_sales: total_sales,
            order_count: order_count,
            average_order_value: average_order_value
          },
          sales_by_status: sales_by_status,
          sales_by_day: sales_by_day,
          top_products: top_products
        }, status: :ok
      end

      # GET /api/v1/reports/inventory
      def inventory
        authorize :report, :view_inventory?

        # Get inventory status counts
        total_items = InventoryItem.count
        low_stock_items = InventoryItem.joins(:product)
                                       .where("quantity < products.reorder_point")
                                       .count
        out_of_stock_items = InventoryItem.where(quantity: 0).count

        # Get inventory value
        total_inventory_value = InventoryItem.joins(:product)
                                           .sum("quantity * products.unit_cost")

        # Get inventory by location
        inventory_by_location = Location.joins(:inventory_items)
                                        .group("locations.id", "locations.name")
                                        .select("locations.id, locations.name, COUNT(inventory_items.id) as item_count, SUM(inventory_items.quantity * products.unit_cost) as total_value")
                                        .joins("INNER JOIN products ON inventory_items.product_id = products.id")
                                        .order("total_value DESC")
                                        .map do |loc|
                                          {
                                            id: loc.id,
                                            name: loc.name,
                                            item_count: loc.item_count,
                                            total_value: loc.total_value
                                          }
                                        end

        # Get top products by value
        top_products_by_value = InventoryItem.joins(:product)
                                            .group("products.id", "products.name")
                                            .select("products.id, products.name, SUM(inventory_items.quantity) as total_quantity, SUM(inventory_items.quantity * products.unit_cost) as total_value")
                                            .order("total_value DESC")
                                            .limit(10)
                                            .map do |item|
                                              {
                                                id: item.id,
                                                name: item.name,
                                                total_quantity: item.total_quantity,
                                                total_value: item.total_value
                                              }
                                            end

        # Get items that need reordering
        reorder_needed = InventoryItem.joins(:product)
                                     .where("quantity < products.reorder_point")
                                     .select("inventory_items.id, products.id as product_id, products.name, inventory_items.quantity, products.reorder_point")
                                     .order("(products.reorder_point - inventory_items.quantity) DESC")
                                     .limit(20)
                                     .map do |item|
                                       {
                                         id: item.id,
                                         product_id: item.product_id,
                                         name: item.name,
                                         current_quantity: item.quantity,
                                         reorder_point: item.reorder_point,
                                         shortage: item.reorder_point - item.quantity
                                       }
                                     end

        render json: {
          report_type: "inventory",
          summary: {
            total_items: total_items,
            low_stock_items: low_stock_items,
            out_of_stock_items: out_of_stock_items,
            total_inventory_value: total_inventory_value
          },
          inventory_by_location: inventory_by_location,
          top_products_by_value: top_products_by_value,
          reorder_needed: reorder_needed
        }, status: :ok
      end

      # GET /api/v1/reports/suppliers
      def suppliers
        authorize :report, :view_supplier_performance?

        # Get date range parameters
        start_date = params[:start_date] ? Date.parse(params[:start_date]) : 90.days.ago.to_date
        end_date = params[:end_date] ? Date.parse(params[:end_date]) : Date.today

        # Get purchase orders in date range
        purchase_orders = PurchaseOrder.where(created_at: start_date.beginning_of_day..end_date.end_of_day)

        # Get supplier performance
        supplier_performance = Supplier.joins(:purchase_orders)
                                     .where(purchase_orders: { created_at: start_date.beginning_of_day..end_date.end_of_day })
                                     .group("suppliers.id", "suppliers.name")
                                     .select('
                                       suppliers.id,
                                       suppliers.name,
                                       COUNT(purchase_orders.id) as order_count,
                                       SUM(purchase_orders.total_amount) as total_spent,
                                       AVG(CASE WHEN purchase_orders.status = \'completed\' THEN
                                         EXTRACT(EPOCH FROM (purchase_orders.updated_at - purchase_orders.created_at))/86400.0
                                       ELSE NULL END) as avg_fulfillment_days
                                     ')
                                     .order("total_spent DESC")
                                     .map do |sup|
                                       {
                                         id: sup.id,
                                         name: sup.name,
                                         order_count: sup.order_count,
                                         total_spent: sup.total_spent,
                                         avg_fulfillment_days: sup.avg_fulfillment_days ? sup.avg_fulfillment_days.round(1) : nil
                                       }
                                     end

        render json: {
          report_type: "suppliers",
          date_range: {
            start_date: start_date,
            end_date: end_date
          },
          supplier_performance: supplier_performance
        }, status: :ok
      end
    end
  end
end
